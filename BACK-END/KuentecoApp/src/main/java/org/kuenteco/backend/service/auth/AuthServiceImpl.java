package org.kuenteco.backend.service.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Collection;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.config.jwt.JwtUtil;
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.entity.Role;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.exception.exceptions.AuthException;
import org.kuenteco.backend.mapper.auth.NewUserMapper;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveRoleRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.email.SendgridService;
import org.kuenteco.backend.service.user.UserService;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final CookieService cookieService;
    private final UserService userService;
    private final SlaveRoleRepository slaveRoleRepository;
    private final MasterUserRepository masterUserRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final TokenBlacklistService tokenBlacklistService;
    private final TransactionTemplate transactionTemplate;
    private final NewUserMapper newUserMapper;
    private final SendgridService sendgridService;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    protected final Map<String, String> verificationCodes = new ConcurrentHashMap<>();

    @Override
    public TokenResponseDTO authenticate(LoginDTO dto, HttpServletResponse response) {
        // Verificar si la cuenta está activa antes de autenticar
        // Determinar si es un email o nombre de usuario
        User user =
                Optional.ofNullable(userService.findByNameOrEmail(dto.nameOrEmail))
                        .filter(u -> u.getState() == State.ACTIVE)
                        .orElseThrow(
                                () ->
                                        new AuthException(
                                                "Credenciales Invalidas, verifique sus datos e intente nuevamente"));

        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(user.getEmail(), dto.password);

        Authentication authResult =
                authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        SecurityContextHolder.getContext().setAuthentication(authResult);

        String jwt = jwtUtil.generateToken(authResult);
        cookieService.addHttpOnlyCookie("jwt", jwt, 7 * 24 * 60 * 60, response);

        return TokenResponseDTO.builder().token(jwt).type(user.getType().name()).build();
    }

    @Override
    public void addUser(NewUserDTO dto) {
        if (userService.existsByUserName(dto.getUsername())) {
            throw new AuthException(
                    "Datos Inválidos, nombre con caracteres no permitidos o ya existente");
        } else if (userService.existsByUserEmail(dto.getEmail())) {
            throw new AuthException(
                    "Datos Inválidos, correo con caracteres no permitidos o ya existente");
        }
        log.info("Registrando nuevo usuario: {}", dto.getEmail());

        Role role =
                slaveRoleRepository
                        .findByName(RoleList.ROLE_USER)
                        .orElseThrow(() -> new AuthException("Role no encontrado"));

        // Asegurar que el rol existe en la base de datos maestra
        Role masterRole = role; // Usar el rol ya obtenido

        // Utilizar transacción explícita para guardar el usuario
        transactionTemplate.execute(
                status -> {
                    // Crear y configurar el usuario
                    User user = newUserMapper.toEntity(dto);
                    user.setPassword(passwordEncoder.encode(dto.getPassword()));
                    user.setRole(masterRole);
                    user.setState(State.PENDING);
                    user.setVersion(0);

                    // PRIMERO: Guardar el usuario para que obtenga su ID
                    User savedUser = masterUserRepository.save(user);

                    // SEGUNDO: Crear la subscription con el usuario ya persistido
                    Subscription subscription =
                            Subscription.builder()
                                    .user(savedUser) // ← Ahora el user tiene ID
                                    .state(State.INACTIVE)
                                    .type(SubscriptionType.BASIC)
                                    .build();

                    // TERCERO: Guardar la subscription
                    masterSubscriptionRepository.save(subscription);

                    return "Usuario registrado correctamente";
                });

        // Enviar código de verificación automáticamente
        sendgridService.sendVerificationEmail(new SendVerificationCodeDTO(dto.getEmail()), true);
    }

    @Override
    public void activateUser(String email) {
        // Usar transacción explícita en lugar de anotación para mejor control
        Boolean result =
                transactionTemplate.execute(
                        status -> {
                            // Buscar directamente en la base de datos maestra, no en la esclava
                            User user =
                                    slaveUserRepository
                                            .findByEmail(email)
                                            .orElseThrow(
                                                    () ->
                                                            new AuthException(
                                                                    "Usuario no encontrado"));

                            // Verificar si la cuenta ya está activada
                            if (State.ACTIVE.equals(user.getState())) {
                                return true; // Ya está activada, operación exitosa
                            }

                            // Activar la cuenta
                            user.setState(State.ACTIVE);
                            masterUserRepository.save(user);

                            // Eliminar el código después de usarlo
                            verificationCodes.remove(email);

                            return true;
                        });
        if (result == null || !result) {
            throw new AuthException("No se pudo activar la cuenta. Por favor, intente nuevamente.");
        }
    }

    @Override
    public String changePasswordWithVerification(ChangePasswordDTO changePasswordDTO) {
        // Usar transacción para cambiar la contraseña
        return transactionTemplate.execute(
                status -> {
                    // Buscar directamente en la base de datos maestra
                    User user =
                            slaveUserRepository
                                    .findByEmail(changePasswordDTO.getEmail())
                                    .orElseThrow(() -> new AuthException("Usuario no encontrado"));

                    // Verificar que la cuenta esté activa
                    if (user.getState() != State.ACTIVE) {
                        throw new AuthException("La cuenta no está activa");
                    }

                    user.setPassword(passwordEncoder.encode(changePasswordDTO.getNewPassword()));
                    masterUserRepository.save(user);

                    // Eliminar el código después de usarlo
                    verificationCodes.remove(changePasswordDTO.getEmail());

                    return "Contraseña actualizada correctamente";
                });
    }

    @Override
    public void logout(HttpServletRequest request, HttpServletResponse response) {
        // Obtener el token del request
        String token = jwtUtil.resolveToken(request);

        if (token == null) {
            throw new AuthException("Token no proporcionado");
        }
        // 1. Invalidar el token
        tokenBlacklistService.addToBlacklist(token);

        // 2. Limpiar la cookie
        cookieService.deleteCookie("jwt", response);

        // 3. Limpiar el contexto de seguridad
        SecurityContextHolder.clearContext();
    }

    public static AuthCredentials getCredentials() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException(
                    "No hay usuario autenticado en el contexto de seguridad");
        }

        String email = authentication.getName();
        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
        if (authorities.isEmpty()) {
            throw new IllegalStateException("No se encontraron roles en las credenciales");
        }

        String roleName = authorities.iterator().next().getAuthority();
        RoleList role;
        try {
            role = RoleList.valueOf(roleName);
        } catch (IllegalArgumentException e) {
            throw new IllegalStateException("Rol desconocido: " + roleName);
        }

        log.info("Obteniendo información para: {}, con el rol {}", email, roleName);
        return new AuthCredentials(email, role);
    }
}
