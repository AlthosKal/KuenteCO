package org.kuenteco.backend.service.jwt;

import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.dto.auth.NewUserDTO;
import org.kuenteco.backend.dto.auth.SendVerificationCodeDTO;
import org.kuenteco.backend.entity.master.MasterRole;
import org.kuenteco.backend.entity.master.MasterUser;
import org.kuenteco.backend.entity.slave.SlaveRole;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.jwt.JwtUtil;
import org.kuenteco.backend.mapper.entity.RoleMapper;
import org.kuenteco.backend.mapper.entity.UserMapper;
import org.kuenteco.backend.repository.master.MasterRoleRepository;
import org.kuenteco.backend.repository.slave.SlaveRoleRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Service
public class AuthServiceImpl implements AuthService {
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final CookieServiceImpl cookieService;
    private final UserService userService;
    private final SlaveRoleRepository slaveRoleRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final TokenBlacklistService tokenBlacklistService;

    @Autowired
    private MasterRoleRepository masterRoleRepository;
    private final UserMapper userMapper;
    private final RoleMapper roleMapper;

    @Value("${spring.sendgrid.api-key}")
    private String SENDGRID_API_KEY;

    @Value("${spring.sendgrid.email}")
    private String EmailSendGrid;

    private final Map<String, String> verificationCodes = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    @Autowired
    public AuthServiceImpl(UserService userService, PasswordEncoder passwordEncoder, JwtUtil jwtUtil,
            AuthenticationManagerBuilder authenticationManagerBuilder, CookieServiceImpl cookieService,
            TokenBlacklistService tokenBlacklistService, SlaveRoleRepository slaveRoleRepository,
            SlaveUserRepository slaveUserRepository, UserMapper userMapper, RoleMapper roleMapper) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManagerBuilder = authenticationManagerBuilder;
        this.cookieService = cookieService;
        this.tokenBlacklistService = tokenBlacklistService;
        this.slaveRoleRepository = slaveRoleRepository;
        this.slaveUserRepository = slaveUserRepository;
        this.userMapper = userMapper;
        this.roleMapper = roleMapper;
    }

    @Override
    public String authenticate(String email, String password, HttpServletResponse response) {
        // Verificar si la cuenta está activa antes de autenticar
        SlaveUser slaveUser = slaveUserRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        MasterUser user = userMapper.slaveToMaster(slaveUser);
        if (user.getAccountState() != State.ACTIVE) {
            throw new RuntimeException("Account no activada. Por favor verifica tu correo");
        }

        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(email,
                password);
        Authentication authResult = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        SecurityContextHolder.getContext().setAuthentication(authResult);

        String jwt = jwtUtil.generateToken(authResult);
        cookieService.addHttpOnlyCookie("jwt", jwt, 7 * 24 * 60 * 60, response);
        return jwt;
    }

    @Override
    public void registerUser(NewUserDTO newUserDTO) {
        if (userService.existsByUserName(newUserDTO.getEmail())) {
            throw new IllegalArgumentException("Datos Invalidos, correo incorrecto o ya existente");
        }

        SlaveRole slaveRole = slaveRoleRepository.findByName(RoleList.ROLE_USER)
                .orElseThrow(() -> new RuntimeException("Role no encontrado"));

        MasterRole roleUser = roleMapper.slaveToMaster(slaveRole);

        // Asegurar que el rol existe en la base de datos maestra
        MasterRole masterRole = masterRoleRepository.findByName(RoleList.ROLE_USER)
                .orElseGet(() -> masterRoleRepository.save(roleUser));

        // Nuevo usuario se crea con estado PENDING
        MasterUser user = new MasterUser(
                newUserDTO.getEmail(),
                passwordEncoder.encode(newUserDTO.getPassword()),
                masterRole);
        user.setAccountState(State.PENDING);

        userService.saveUser(user);

        // Enviar código de verificación automáticamente
        SendVerificationCodeDTO verificationDTO = new SendVerificationCodeDTO();
        verificationDTO.setEmail(newUserDTO.getEmail());
        try {
            sendVerificationEmail(verificationDTO, true);
        } catch (IOException e) {
            throw new RuntimeException("Error enviando correo de verificación", e);
        }
    }

    @Override
    public void sendVerificationEmail(SendVerificationCodeDTO sendVerificationCodeDTO, boolean isRegistration)
            throws IOException {
        String email = sendVerificationCodeDTO.getEmail();

        if (isRegistration && !slaveUserRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email no registrado");
        }

        String code = String.format("%06d", new Random().nextInt(999999));
        verificationCodes.put(email, code);

        // Programar la eliminación del código después de 15 minutos
        scheduler.schedule(() -> verificationCodes.remove(email), 15, TimeUnit.MINUTES);

        scheduler.schedule(() -> userService.deletePendingEmail(email), 15, TimeUnit.MINUTES);

        Email from = new Email(EmailSendGrid);
        String subject = isRegistration ? "Verifica tu registro en KuenteCO" : "Código de recuperación de contraseña";

        String contentText = isRegistration ? "Tu código de verificación para activar tu cuenta es: " + code
                : "Tu código para recuperar tu contraseña es: " + code;

        Mail mail = new Mail(from, subject, new Email(email), new Content("text/plain", contentText));

        SendGrid sg = new SendGrid(SENDGRID_API_KEY);
        Request request = new Request();
        try {
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            Response response = sg.api(request);

            if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
                throw new IOException("Error en el envio del correo: " + response.getBody());
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

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    @Override
    public void activateUser(String email) {
        SlaveUser slaveUser = slaveUserRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        if (slaveUser.getAccountState() == State.ACTIVE) {
            throw new RuntimeException("Tu cuenta ha sido activada");
        }

        MasterUser user = userMapper.slaveToMaster(slaveUser);
        user.setAccountState(State.ACTIVE);
        userService.saveUser(user);

        // Eliminar el código después de usarlo
        verificationCodes.remove(email);
    }

    @Override
    public String changePasswordWithVerification(String email, String code, String newPassword) {
        if (!validateVerificationCode(email, code)) {
            throw new RuntimeException("Codigo de Verificación Invalido");
        }

        SlaveUser slaveUser = slaveUserRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no Encontrado"));

        MasterUser user = userMapper.slaveToMaster(slaveUser);
        user.setPassword(passwordEncoder.encode(newPassword));
        userService.saveUser(user);

        verificationCodes.remove(email);

        return "Contraseña actualizada correctamente";
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