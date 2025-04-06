    package org.kuenteco.backend.service.auth;

    import com.sendgrid.Method;
    import com.sendgrid.Request;
    import com.sendgrid.Response;
    import com.sendgrid.SendGrid;
    import com.sendgrid.helpers.mail.Mail;
    import com.sendgrid.helpers.mail.objects.Email;
    import com.sendgrid.helpers.mail.objects.Personalization;
    import jakarta.servlet.http.HttpServletResponse;
    import org.kuenteco.backend.dto.auth.NewUserDTO;
    import org.kuenteco.backend.dto.auth.SendVerificationCodeDTO;
    import org.kuenteco.backend.dto.image.ImageDTO;
    import org.kuenteco.backend.entity.master.MasterRole;
    import org.kuenteco.backend.entity.master.MasterUser;
    import org.kuenteco.backend.entity.master.extra.MasterImage;
    import org.kuenteco.backend.entity.slave.SlaveRole;
    import org.kuenteco.backend.entity.slave.SlaveUser;
    import org.kuenteco.backend.enums.RoleList;
    import org.kuenteco.backend.enums.State;
    import org.kuenteco.backend.jwt.JwtUtil;
    import org.kuenteco.backend.mapper.dto.ImageMapper;
    import org.kuenteco.backend.mapper.entity.RoleMapper;
    import org.kuenteco.backend.mapper.entity.UserMapper;
    import org.kuenteco.backend.repository.master.MasterRoleRepository;
    import org.kuenteco.backend.repository.master.MasterUserRepository;
    import org.kuenteco.backend.repository.slave.SlaveRoleRepository;
    import org.kuenteco.backend.repository.slave.SlaveUserRepository;
    import org.kuenteco.backend.service.image.ImageService;
    import org.slf4j.Logger;
    import org.slf4j.LoggerFactory;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.beans.factory.annotation.Qualifier;
    import org.springframework.beans.factory.annotation.Value;
    import org.springframework.dao.OptimisticLockingFailureException;
    import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
    import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
    import org.springframework.security.core.Authentication;
    import org.springframework.security.core.context.SecurityContextHolder;
    import org.springframework.security.crypto.password.PasswordEncoder;
    import org.springframework.stereotype.Service;
    import org.springframework.transaction.PlatformTransactionManager;
    import org.springframework.transaction.TransactionDefinition;
    import org.springframework.transaction.support.TransactionTemplate;
    import org.springframework.web.multipart.MultipartFile;

    import java.io.IOException;
    import java.util.Map;
    import java.util.Optional;
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
        private final CookieService cookieService;
        private final UserService userService;
        private final ImageService imageService;
        private final SlaveRoleRepository slaveRoleRepository;
        private final SlaveUserRepository slaveUserRepository;
        private final TokenBlacklistService tokenBlacklistService;
        private final TransactionTemplate masterTransactionTemplate;
        private final MasterUserRepository masterUserRepository;
        private final MasterRoleRepository masterRoleRepository;
        private final UserMapper userMapper;
        private final RoleMapper roleMapper;
        private final ImageMapper imageMapper;

        //SendGrid
        @Value("${spring.sendgrid.api-key}")
        private String SENDGRID_API_KEY;

        @Value("${spring.sendgrid.email}")
        private String EmailSendGrid;

        @Value("${spring.sendgrid.functions.verify-email}")
        private String VerifyEmail;

        @Value("${spring.sendgrid.functions.reset-password}")
        private String ResetPassword;

        private final Map<String, String> verificationCodes = new ConcurrentHashMap<>();
        private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

        private static final Logger log = LoggerFactory.getLogger(AuthServiceImpl.class);

        @Autowired
        public AuthServiceImpl(UserService userService, PasswordEncoder passwordEncoder, JwtUtil jwtUtil,
                AuthenticationManagerBuilder authenticationManagerBuilder, CookieService cookieService,
                TokenBlacklistService tokenBlacklistService, SlaveRoleRepository slaveRoleRepository,
                SlaveUserRepository slaveUserRepository, UserMapper userMapper, RoleMapper roleMapper,
                MasterUserRepository masterUserRepository, MasterRoleRepository masterRoleRepository,
                @Qualifier("masterTransactionManager") PlatformTransactionManager masterTransactionManager,
                               ImageService imageService, ImageMapper imageMapper) {
            this.userService = userService;
            this.passwordEncoder = passwordEncoder;
            this.jwtUtil = jwtUtil;
            this.authenticationManagerBuilder = authenticationManagerBuilder;
            this.cookieService = cookieService;
            this.tokenBlacklistService = tokenBlacklistService;
            this.masterRoleRepository = masterRoleRepository;
            this.slaveRoleRepository = slaveRoleRepository;
            this.slaveUserRepository = slaveUserRepository;
            this.userMapper = userMapper;
            this.roleMapper = roleMapper;
            this.masterUserRepository = masterUserRepository;
            this.imageService = imageService;
            this.imageMapper = imageMapper;


            // Configuración de transacción con timeout apropiado
            this.masterTransactionTemplate = new TransactionTemplate(masterTransactionManager);
            this.masterTransactionTemplate.setTimeout(30); // 30 segundos
            this.masterTransactionTemplate.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
        }

        @Override
        public String authenticate(String nameOrEmail, String password, HttpServletResponse response) {
            // Verificar si la cuenta está activa antes de autenticar
            // Determinar si es un email o nombre de usuario
            SlaveUser slaveUser = userService.findByNameOrEmail(nameOrEmail);

            MasterUser user = userMapper.slaveToMaster(slaveUser);
            if (user.getAccountState() != State.ACTIVE) {
                throw new RuntimeException("Cuenta no activada. Por favor verifica tu correo");
            }

            // Usar el email para la autenticación de Spring Security
            String emailForAuth = slaveUser.getEmail();

            UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(emailForAuth,
                    password);
            Authentication authResult = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
            SecurityContextHolder.getContext().setAuthentication(authResult);

            String jwt = jwtUtil.generateToken(authResult);
            cookieService.addHttpOnlyCookie("jwt", jwt, 7 * 24 * 60 * 60, response);

            return slaveUser.getSlaveRole().getName().toString();
        }

        @Override
        public void registerUser(NewUserDTO newUserDTO) {
            if (userService.existsByUserName(newUserDTO.getName())) {
                throw new IllegalArgumentException("Datos Inválidos, nombre con caracteres no permitidos o ya existente");
            }
            if (userService.existsByUserEmail(newUserDTO.getEmail())) {
                throw new IllegalArgumentException("Datos Inválidos, correo con caracteres no permitidos o ya existente");
            }

            log.info("Intentando registrar nuevo usuario: {}", newUserDTO.getEmail());

            SlaveRole slaveRole = slaveRoleRepository.findByName(RoleList.ROLE_USER)
                    .orElseThrow(() -> new RuntimeException("Role no encontrado"));

            MasterRole roleUser = roleMapper.slaveToMaster(slaveRole);

            // Asegurar que el rol existe en la base de datos maestra
            MasterRole masterRole = masterRoleRepository.findByName(RoleList.ROLE_USER)
                    .orElseGet(() -> masterRoleRepository.save(roleUser));

            // Utilizar transacción explícita para guardar el usuario
            masterTransactionTemplate.execute(status -> {
                try {
                    // Nuevo usuario se crea con estado PENDING
                    MasterUser user = new MasterUser(
                            newUserDTO.getName(),
                            newUserDTO.getEmail(),
                            passwordEncoder.encode(newUserDTO.getPassword()), masterRole);
                    user.setAccountState(State.PENDING);
                    user.setVersion(0); // Inicializar versión para bloqueo optimista

                    userService.saveUser(user);
                    return null;
                } catch (Exception e) {
                    status.setRollbackOnly();
                    throw new RuntimeException("Error al registrar usuario", e);
                }
            });

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
            log.info("Código de verificacion: " + code);

            // Programar la eliminación del código después de 15 minutos
            scheduler.schedule(() -> verificationCodes.remove(email), 15, TimeUnit.MINUTES);
            scheduler.schedule(() -> userService.deletePendingEmail(email), 15, TimeUnit.MINUTES);

            Email from = new Email(EmailSendGrid);
            Email to = new Email(email);

            // Elegir la plantilla adecuada basada en el tipo de verificación
            String templateId = isRegistration ?
                    VerifyEmail : // Verificación de email
                    ResetPassword; // Recuperación de contraseña

            // Crear personalización con datos dinámicos
            Mail mail = new Mail();
            mail.setFrom(from);
            mail.setSubject(isRegistration ? "Verifica tu registro en KuenteCO" : "Código de recuperación de contraseña");

            Personalization personalization = new Personalization();
            personalization.addTo(to);

            // Agregar datos dinámicos a la plantilla
            if (isRegistration) {
                personalization.addDynamicTemplateData("codeVerificationEmail", code);
                // URL de verificación:
                // personalization.addDynamicTemplateData("verification_url", "https://kuenteco.com/verify?email=" + email);
            } else {
                personalization.addDynamicTemplateData("codeResetPassword", code);
                // URL de reset:
                // personalization.addDynamicTemplateData("reset_password_url", "https://kuenteco.com/reset-password?email=" + email);
            }

            mail.addPersonalization(personalization);
            mail.setTemplateId(templateId);

            SendGrid sg = new SendGrid(SENDGRID_API_KEY);
            Request request = new Request();
            try {
                request.setMethod(Method.POST);
                request.setEndpoint("mail/send");
                request.setBody(mail.build());
                Response response = sg.api(request);

                if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
                    throw new IOException("Error en el envío del correo: " + response.getBody());
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
            // Usar transacción explícita en lugar de anotación para mejor control
            Boolean result = masterTransactionTemplate.execute(status -> {
                try {
                    // Buscar directamente en la base de datos maestra, no en la esclava
                    Optional<MasterUser> masterUserOpt = masterUserRepository.findByEmail(email);

                    if (masterUserOpt.isEmpty()) {
                        throw new RuntimeException("Usuario no encontrado");
                    }

                    MasterUser masterUser = masterUserOpt.get();

                    // Verificar si la cuenta ya está activada
                    if (State.ACTIVE.equals(masterUser.getAccountState())) {
                        return true; // Ya está activada, operación exitosa
                    }

                    // Activar la cuenta
                    masterUser.setAccountState(State.ACTIVE);
                    masterUserRepository.save(masterUser);

                    // Eliminar el código después de usarlo
                    verificationCodes.remove(email);

                    return true;
                } catch (OptimisticLockingFailureException e) {
                    // Manejar específicamente fallos de bloqueo optimista
                    status.setRollbackOnly();
                    throw new RuntimeException("Error de concurrencia al activar la cuenta. Por favor, intente nuevamente.",
                            e);
                } catch (Exception e) {
                    status.setRollbackOnly();
                    throw new RuntimeException("Error al activar la cuenta: " + e.getMessage(), e);
                }
            });

            if (result == null || !result) {
                throw new RuntimeException("No se pudo activar la cuenta. Por favor, intente nuevamente.");
            }
        }

        @Override
        public String changePasswordWithVerification(String email, String code, String newPassword) {
            // Usar transacción para cambiar la contraseña
            return masterTransactionTemplate.execute(status -> {
                try {
                    // Buscar directamente en la base de datos maestra
                    Optional<MasterUser> masterUserOpt = masterUserRepository.findByEmail(email);

                    if (masterUserOpt.isEmpty()) {
                        throw new RuntimeException("Usuario no encontrado");
                    }

                    MasterUser masterUser = masterUserOpt.get();

                    // Verificar que la cuenta esté activa
                    if (masterUser.getAccountState() != State.ACTIVE) {
                        throw new RuntimeException("La cuenta no está activa");
                    }

                    // Comprobar política de contraseñas mínimas
                    if (newPassword.length() < 6) {
                        throw new RuntimeException("La contraseña debe tener al menos 6 caracteres");
                    }

                    masterUser.setPassword(passwordEncoder.encode(newPassword));
                    masterUserRepository.save(masterUser);

                    // Eliminar el código después de usarlo
                    verificationCodes.remove(email);

                    return "Contraseña actualizada correctamente";
                } catch (OptimisticLockingFailureException e) {
                    status.setRollbackOnly();
                    throw new RuntimeException(
                            "Error de concurrencia al cambiar la contraseña. Por favor, intente nuevamente.", e);
                } catch (Exception e) {
                    status.setRollbackOnly();
                    throw new RuntimeException("Error al cambiar la contraseña: " + e.getMessage(), e);
                }
            });
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

        @Override
        public ImageDTO saveImage(MultipartFile image, String token, HttpServletResponse response) {
            try {
                String username = jwtUtil.extractEmail(token);
                MasterUser user = masterUserRepository.findByName(username)
                        .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

                // Verificar si ya tiene una imagen previa
                if (user.getMasterImage() != null) {
                    throw new RuntimeException("El usuario ya tiene una imagen de perfil. Utilice updateImage para actualizarla.");
                }

                // Subir la nueva imagen
                MasterImage masterImage = imageService.uploadImage(image);
                user.setMasterImage(masterImage);
                masterUserRepository.save(user);

                return imageMapper.toDTO(masterImage);
            } catch (IOException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                throw new RuntimeException("Error al guardar la imagen: " + e.getMessage());
            }
        }

        @Override
        public ImageDTO updateImage(MultipartFile image, String token, HttpServletResponse response) {
            try {
                String username = jwtUtil.extractEmail(token);
                MasterUser user = masterUserRepository.findByName(username)
                        .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

                // Verificar si tiene imagen para actualizar
                if (user.getMasterImage() == null) {
                    throw new RuntimeException("El usuario no tiene una imagen de perfil para actualizar.");
                }

                // Eliminar la imagen anterior
                imageService.deleteImage(user.getMasterImage());

                // Subir la nueva imagen
                MasterImage masterImage = imageService.uploadImage(image);
                user.setMasterImage(masterImage);
                masterUserRepository.save(user);

                return imageMapper.toDTO(masterImage);
            } catch (IOException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                throw new RuntimeException("Error al actualizar la imagen: " + e.getMessage());
            }
        }

        @Override
        public void deleteImage(String token, HttpServletResponse response) {
            try {
                String username = jwtUtil.extractEmail(token);
                MasterUser user = masterUserRepository.findByName(username)
                        .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

                // Verificar si tiene imagen para eliminar
                if (user.getMasterImage() == null) {
                    throw new RuntimeException("El usuario no tiene una imagen de perfil para eliminar.");
                }

                // Eliminar la imagen
                MasterImage imageToDelete = user.getMasterImage();
                user.setMasterImage(null);
                masterUserRepository.save(user);

                imageService.deleteImage(imageToDelete);

                response.setStatus(HttpServletResponse.SC_OK);
            } catch (IOException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                throw new RuntimeException("Error al eliminar la imagen: " + e.getMessage());
            }
        }
    }