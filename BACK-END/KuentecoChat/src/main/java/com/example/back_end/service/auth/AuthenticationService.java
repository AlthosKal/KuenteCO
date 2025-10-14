package com.example.back_end.service.auth;

import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.connector.config.KuentecoEndpoint;
import com.example.back_end.connector.rest.auth.LoginDTO;
import com.example.back_end.connector.rest.auth.TokenResponseDTO;
import com.example.back_end.exception.ApiResponse;
import com.example.back_end.service.session.SessionManager;
import com.fasterxml.jackson.core.type.TypeReference;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final SessionManager sessionManager;
    private final KuentecoAppConnector kuentecoAppConnector;

    // Patrones para extraer credenciales del mensaje del usuario
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile(
                    "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b",
                    Pattern.CASE_INSENSITIVE);
    private static final Pattern CREDENTIAL_PATTERN =
            Pattern.compile(
                    "(?:usuario|correo|email|user)\\s*:?\\s*([^\\s,]+).*?(?:contraseña|password|clave)\\s*:?\\s*([^\\s,]+)",
                    Pattern.CASE_INSENSITIVE | Pattern.DOTALL);

    /**
     * Intenta extraer credenciales del mensaje del usuario
     *
     * @param userMessage El mensaje del usuario
     * @return LoginDTO con las credenciales o null si no se encontraron
     */
    public LoginDTO extractCredentials(String userMessage) {
        if (userMessage == null || userMessage.trim().isEmpty()) {
            return null;
        }

        String nameOrEmail = null;
        String password = null;

        // Intentar extraer con el patrón completo
        Matcher credentialMatcher = CREDENTIAL_PATTERN.matcher(userMessage);
        if (credentialMatcher.find()) {
            nameOrEmail = credentialMatcher.group(1).trim();
            password = credentialMatcher.group(2).trim();
        } else {
            // Intentar extraer email
            Matcher emailMatcher = EMAIL_PATTERN.matcher(userMessage);
            if (emailMatcher.find()) {
                nameOrEmail = emailMatcher.group().trim();
                // Intentar encontrar la contraseña después del email
                Pattern passwordAfterEmail =
                        Pattern.compile(
                                nameOrEmail
                                        + ".*?(?:contraseña|password|clave)\\s*:?\\s*([^\\s,]+)",
                                Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
                Matcher passwordMatcher = passwordAfterEmail.matcher(userMessage);
                if (passwordMatcher.find()) {
                    password = passwordMatcher.group(1).trim();
                }
            }
        }

        // Si encontramos ambas credenciales, retornar el DTO
        if (nameOrEmail != null && password != null) {
            log.info("Credentials extracted from message for user: {}", nameOrEmail);
            return new LoginDTO(nameOrEmail, password);
        }

        log.debug("No credentials found in message");
        return null;
    }

    /**
     * Autentica al usuario con las credenciales proporcionadas
     *
     * @param identifier Identificador de la sesión (número de teléfono o CallSid)
     * @param credentials Las credenciales del usuario
     * @return Mensaje de respuesta para el usuario
     */
    public String authenticateUser(String identifier, LoginDTO credentials) {
        try {
            log.info(
                    "Attempting authentication for session {} with user: {}",
                    identifier,
                    credentials.nameOrEmail());

            // Llamar al endpoint de autenticación (POST con body JSON, sin autenticación)
            ApiResponse<TokenResponseDTO> response =
                    kuentecoAppConnector.callWithBody(
                            KuentecoEndpoint.AUTH_USER,
                            credentials,
                            new TypeReference<>() {},
                            false);

            if (response.isSuccess() && response.getData() != null) {
                TokenResponseDTO tokenData = response.getData();

                // Marcar la sesión como autenticada
                sessionManager.authenticateSession(
                        identifier, credentials.nameOrEmail(), tokenData.getToken());

                log.info("Authentication successful for session {}", identifier);
                return "¡Autenticación exitosa! Ahora puedes consultarme sobre tus finanzas. ¿En qué puedo ayudarte?";
            } else {
                // Autenticación fallida
                boolean blocked = sessionManager.recordFailedAttempt(identifier);
                int remainingAttempts = sessionManager.getRemainingAttempts(identifier);

                log.warn(
                        "Authentication failed for session {}. Remaining attempts: {}",
                        identifier,
                        remainingAttempts);

                if (blocked) {
                    return "Has excedido el número máximo de intentos de autenticación. Tu sesión ha sido bloqueada temporalmente por 1 hora.";
                } else {
                    return String.format(
                            "Credenciales incorrectas. Te quedan %d intento(s). Por favor, proporciona tu correo o nombre de usuario y contraseña nuevamente.",
                            remainingAttempts);
                }
            }
        } catch (Exception e) {
            log.error("Error during authentication for session {}", identifier, e);
            boolean blocked = sessionManager.recordFailedAttempt(identifier);
            int remainingAttempts = sessionManager.getRemainingAttempts(identifier);

            if (blocked) {
                return "Ha ocurrido un error en la autenticación y has excedido el número máximo de intentos. Tu sesión ha sido bloqueada temporalmente por 1 hora.";
            } else {
                return String.format(
                        "Ha ocurrido un error al validar tus credenciales. Te quedan %d intento(s). Por favor, intenta nuevamente.",
                        remainingAttempts);
            }
        }
    }

    /**
     * Genera un mensaje solicitando credenciales al usuario
     *
     * @param identifier Identificador de la sesión
     * @return Mensaje solicitando credenciales
     */
    public String requestCredentials(String identifier) {
        SessionManager.Session session = sessionManager.getOrCreateSession(identifier);

        if (session.isBlocked()) {
            return "Tu sesión está bloqueada temporalmente debido a múltiples intentos fallidos de autenticación. Por favor, intenta más tarde.";
        }

        int remainingAttempts = sessionManager.getRemainingAttempts(identifier);
        if (session.getFailedAttempts() > 0) {
            return String.format(
                    "Credenciales incorrectas. Te quedan %d intento(s). Por favor, proporciona tu correo o nombre de usuario y contraseña en el formato: 'usuario: tu_email, contraseña: tu_password'",
                    remainingAttempts);
        }

        return "Bienvenido al asistente financiero de KuenteCO. Para comenzar, por favor proporciona tus credenciales en el formato: 'usuario: tu_email, contraseña: tu_password'";
    }
}
