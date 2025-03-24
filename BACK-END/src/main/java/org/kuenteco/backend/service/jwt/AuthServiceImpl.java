package org.kuenteco.backend.service.jwt;

// Imports de Java
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

// Imports de librerías externas
import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;

// Imports de Spring Framework
import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

// Imports de tu proyecto
import org.kuenteco.backend.dto.auth.NewUserDTO;
import org.kuenteco.backend.dto.auth.VerificationCodeDTO;
import org.kuenteco.backend.entity.Role;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.jwt.JwtUtil;
import org.kuenteco.backend.repository.RoleRepository;

@Service
public class AuthServiceImpl implements AuthService {
    private final UserServiceImpl userService;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final CookieServiceImpl cookieService;
    private final UserRepository userRepository;

    @Value("${spring.sendgrid.api-key}")
    private String SENDGRID_API_KEY;

    // Mapa temporal para almacenar códigos de verificación (en producción, usa una base de datos o caché)
    private final Map<String, String> verificationCodes = new HashMap<>();

    @Autowired
    public AuthServiceImpl(UserServiceImpl userService, RoleRepository roleRepository, PasswordEncoder passwordEncoder,
            JwtUtil jwtUtil, AuthenticationManagerBuilder authenticationManagerBuilder, CookieServiceImpl cookieService,
            UserRepository userRepository) {
        this.userService = userService;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManagerBuilder = authenticationManagerBuilder;
        this.cookieService = cookieService;
        this.userRepository = userRepository;
    }

    public String authenticate(String email, String password, HttpServletResponse response) {
        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(email,
                password);
        Authentication authResult = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        SecurityContextHolder.getContext().setAuthentication(authResult);

        String jwt = jwtUtil.generateToken(authResult);
        cookieService.addHttpOnlyCookie("jwt", jwt, 7 * 24 * 60 * 60, response);
        return jwt;
    }

    public void registerUser(NewUserDTO newUserDTO) {
        if (userService.existsByUserName(newUserDTO.getEmail())) {
            throw new IllegalArgumentException("User already exists");
        }

        Role roleUser = roleRepository.findByName(RoleList.ROLE_USER)
                .orElseThrow(() -> new RuntimeException("Role not found"));
        User user = new User(newUserDTO.getEmail(), passwordEncoder.encode(newUserDTO.getPassword()), roleUser);
        userService.saveUser(user);
    }

    @Override
    public void sendVerificationEmail(VerificationCodeDTO verificationCodeDTO) throws IOException {
        String email = verificationCodeDTO.getEmail();

        // Generar un código de verificación de 6 dígitos
        String code = String.format("%06d", new Random().nextInt(999999));
        verificationCodes.put(email, code); // Almacenar el código temporalmente

        // Configurar el correo electrónico
        Email from = new Email("agudelocastanoyeferson270@gmail.com"); // Cambia por tu correo verificado en SendGrid
        Email to = new Email(email);
        String subject = "Código de verificación";
        Content content = new Content("text/plain", "Tu código de verificación es: " + code);

        Mail mail = new Mail(from, subject, to, content);

        // Enviar el correo usando SendGrid
        SendGrid sg = new SendGrid(SENDGRID_API_KEY);
        Request request = new Request();
        try {
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            Response response = sg.api(request);
            System.out.println("Código de estado: " + response.getStatusCode());
            System.out.println("Respuesta: " + response.getBody());
        } catch (IOException ex) {
            throw ex;
        }
    }

    @Override
    public boolean validateVerificationCode(VerificationCodeDTO verificationCodeDTO) {
        String email = verificationCodeDTO.getEmail();
        String code = verificationCodeDTO.getCode();

        // Verificar si el código coincide con el almacenado
        return verificationCodes.getOrDefault(email, "").equals(code);
    }

    @Override
    public String validateChangePassword(VerificationCodeDTO verificationCodeDTO, String newPassword) {
        // Validar el código de verificación
        if (!validateVerificationCode(verificationCodeDTO)) {
            throw new RuntimeException("Código de verificación inválido");
        }

        // Buscar al usuario por su correo electrónico
        String email = verificationCodeDTO.getEmail();
        User user = userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Cambiar la contraseña
        return changePassword(user, newPassword);
    }

    private String changePassword(User user, String newPassword) {
        user.setPassword(passwordEncoder.encode(newPassword));
        userService.saveUser(user);
        return "Contraseña cambiada con éxito";
    }

    public String changePassword(String newPassword) {
        User user = userService.getUserDetails();
        user.setPassword(passwordEncoder.encode(newPassword));
        userService.saveUser(user);
        return "Password changed successfully";
    }
}