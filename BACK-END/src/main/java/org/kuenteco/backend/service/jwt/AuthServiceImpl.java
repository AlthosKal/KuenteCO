package org.kuenteco.backend.service.jwt;

import com.sendgrid.*;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.entity.Role;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.jwt.JwtUtil;
import org.kuenteco.backend.repository.RoleRepository;
import org.kuenteco.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Service
public class AuthServiceImpl implements AuthService {
    private final UserServiceImpl userService;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final CookieServiceImpl cookieService;
    private final UserRepository userRepository;
    private final TokenBlacklistService tokenBlacklistService;

    @Value("${spring.sendgrid.api-key}")
    private String SENDGRID_API_KEY;

    private final Map<String, String> verificationCodes = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    @Autowired
    public AuthServiceImpl(UserServiceImpl userService, RoleRepository roleRepository,
                           PasswordEncoder passwordEncoder, JwtUtil jwtUtil,
                           AuthenticationManagerBuilder authenticationManagerBuilder,
                           CookieServiceImpl cookieService, UserRepository userRepository,
                           TokenBlacklistService tokenBlacklistService) {
        this.userService = userService;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManagerBuilder = authenticationManagerBuilder;
        this.cookieService = cookieService;
        this.userRepository = userRepository;
        this.tokenBlacklistService = tokenBlacklistService;
    }

    @Override
    public String authenticate(String email, String password, HttpServletResponse response) {
        // Verificar si la cuenta está activa antes de autenticar
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getAccountState() != State.ACTIVE) {
            throw new RuntimeException("Account not activated. Please verify your email");
        }

        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(email, password);
        Authentication authResult = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        SecurityContextHolder.getContext().setAuthentication(authResult);

        String jwt = jwtUtil.generateToken(authResult);
        cookieService.addHttpOnlyCookie("jwt", jwt, 7 * 24 * 60 * 60, response);
        return jwt;
    }

    @Override
    public void registerUser(NewUserDTO newUserDTO) {
        if (userService.existsByUserName(newUserDTO.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }

        Role roleUser = roleRepository.findByName(RoleList.ROLE_USER)
                .orElseThrow(() -> new RuntimeException("Role not found"));

        // Nuevo usuario se crea con estado PENDING
        User user = new User(
                newUserDTO.getEmail(),
                passwordEncoder.encode(newUserDTO.getPassword()),
                roleUser
        );
        user.setAccountState(State.PENDING);

        userService.saveUser(user);

        // Enviar código de verificación automáticamente
        SendVerificationCodeDTO verificationDTO = new SendVerificationCodeDTO();
        verificationDTO.setEmail(newUserDTO.getEmail());
        try {
            sendVerificationEmail(verificationDTO, true);
        } catch (IOException e) {
            throw new RuntimeException("Error sending verification email", e);
        }
    }

    @Override
    public void sendVerificationEmail(SendVerificationCodeDTO sendVerificationCodeDTO, boolean isRegistration) throws IOException {
        String email = sendVerificationCodeDTO.getEmail();

        if (isRegistration && !userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email not registered");
        }

        String code = String.format("%06d", new Random().nextInt(999999));
        verificationCodes.put(email, code);

        // Programar la eliminación del código después de 15 minutos
        scheduler.schedule(() -> verificationCodes.remove(email), 15, TimeUnit.MINUTES);

        Email from = new Email("agudelocastanoyeferson270@gmail.com");
        String subject = isRegistration ?
                "Verifica tu registro en KuenteCO" :
                "Código de recuperación de contraseña";

        String contentText = isRegistration ?
                "Tu código de verificación para activar tu cuenta es: " + code :
                "Tu código para recuperar tu contraseña es: " + code;

        Mail mail = new Mail(
                from,
                subject,
                new Email(email),
                new Content("text/plain", contentText)
        );

        SendGrid sg = new SendGrid(SENDGRID_API_KEY);
        Request request = new Request();
        try {
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            Response response = sg.api(request);

            if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
                throw new IOException("Failed to send email: " + response.getBody());
            }
        } catch (IOException ex) {
            verificationCodes.remove(email);
            throw ex;
        }
    }

    @Override
    public boolean validateVerificationCode(String email, String code) {
        String storedCode = verificationCodes.get(email);
        return code != null && code.equals(storedCode);
    }

    @Override
    public void activateUser(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getAccountState() == State.ACTIVE) {
            throw new RuntimeException("Account already activated");
        }

        user.setAccountState(State.ACTIVE);
        userRepository.save(user);

        // Eliminar el código después de usarlo
        verificationCodes.remove(email);
    }

    @Override
    public String changePasswordWithVerification(String email, String code, String newPassword) {
        if (!validateVerificationCode(email, code)) {
            throw new RuntimeException("Invalid verification code");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        verificationCodes.remove(email);

        return "Password changed successfully";
    }

    @Override
    public void logout(String token, HttpServletResponse response) {
        // 1. Invalidar el token
        tokenBlacklistService.addToBlacklist(token);

        // 2. Limpiar la cookie
        cookieService.deleteCookie("jwt", response);

        // 3. Limpiar el contexto de seguridad
        SecurityContextHolder.clearContext();
    }
}