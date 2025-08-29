package org.kuenteco.auth;

import static org.assertj.core.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.Mockito.doNothing;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.*;
import org.kuenteco.backend.BackEndApplication;
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.AuthException;
import org.kuenteco.backend.repository.master.MasterRoleRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveRoleRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.auth.AuthService;
import org.kuenteco.backend.service.email.SendgridService;
import org.kuenteco.config.BaseIntegrationTestWithoutWireMock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * Pruebas de integración para AuthService. Valida el flujo completo de autenticación con base de
 * datos real y servicios externos mockeados.
 */
@SpringBootTest(classes = BackEndApplication.class)
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class AuthServiceIntegrationTest extends BaseIntegrationTestWithoutWireMock {

    @Autowired private AuthService authService;

    @Autowired private MasterUserRepository masterUserRepository;

    @Autowired private SlaveUserRepository slaveUserRepository;

    @Autowired private SlaveRoleRepository slaveRoleRepository;

    @Autowired private MasterRoleRepository masterRoleRepository;

    @Autowired private PasswordEncoder passwordEncoder;

    @Autowired private MockMvc mockMvc;

    @Autowired private ObjectMapper objectMapper;

    @Autowired private TransactionTemplate transactionTemplate;

    @MockBean private SendgridService sendgridService;

    private static final String BASE_EMAIL = "test%d@kuenteco.org";
    private static final String BASE_USERNAME_PREFIX = "TestUser";
    private static final String TEST_PASSWORD = "TestPassword123@";

    private String getCurrentTestEmail() {
        return String.format(BASE_EMAIL, System.nanoTime());
    }

    private String getCurrentTestUsername() {
        // Crear usernames solo con letras para cumplir con la validación
        long timestamp = System.nanoTime();
        String suffix = String.valueOf(Math.abs(timestamp % 1000)); // Solo últimos 3 dígitos
        return BASE_USERNAME_PREFIX + convertNumberToLetters(suffix);
    }

    private String convertNumberToLetters(String number) {
        StringBuilder result = new StringBuilder();
        for (char digit : number.toCharArray()) {
            // Convertir cada dígito a una letra (0->A, 1->B, etc.)
            result.append((char) ('A' + (digit - '0')));
        }
        return result.toString();
    }

    @BeforeEach
    void setUp() {
        // Limpiar todos los datos de usuarios antes de cada test
        masterUserRepository.deleteAll();
        masterUserRepository.flush();

        // Asegurar que los roles existan después de limpiar
        ensureRolesExist();

        // Configurar mock de SendgridService para evitar llamadas reales
        doNothing().when(sendgridService).sendVerificationEmail(any(), anyBoolean());

        // Esperar un momento para asegurar que las operaciones de base de datos se completen
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private void ensureRolesExist() {
        transactionTemplate.execute(
                status -> {
                    // Verificar si el rol ROLE_USER existe, si no, crearlo
                    if (!slaveRoleRepository.findByName(RoleList.ROLE_USER).isPresent()) {
                        org.kuenteco.backend.entity.Role userRole =
                                new org.kuenteco.backend.entity.Role();
                        userRole.setName(RoleList.ROLE_USER);
                        masterRoleRepository.save(userRole);
                        masterRoleRepository.flush(); // Forzar persistencia inmediata
                    }

                    // Verificar si el rol ROLE_PROFILE existe, si no, crearlo
                    if (!slaveRoleRepository.findByName(RoleList.ROLE_PROFILE).isPresent()) {
                        org.kuenteco.backend.entity.Role profileRole =
                                new org.kuenteco.backend.entity.Role();
                        profileRole.setName(RoleList.ROLE_PROFILE);
                        masterRoleRepository.save(profileRole);
                        masterRoleRepository.flush(); // Forzar persistencia inmediata
                    }

                    return null;
                });

        // Forzar clear del contexto para asegurar que los cambios se propaguen
        masterRoleRepository.flush();

        // Verificar que los roles estén disponibles en el repositorio slave
        if (!slaveRoleRepository.findByName(RoleList.ROLE_USER).isPresent()) {
            throw new RuntimeException("ROLE_USER no está disponible después de la creación");
        }
        if (!slaveRoleRepository.findByName(RoleList.ROLE_PROFILE).isPresent()) {
            throw new RuntimeException("ROLE_PROFILE no está disponible después de la creación");
        }
    }

    @Test
    @Order(1)
    @DisplayName("Debe registrar un nuevo usuario exitosamente")
    void testUserRegistration_Success() throws Exception {
        // Given
        String email = getCurrentTestEmail();
        String username = getCurrentTestUsername();

        NewUserDTO newUserDTO =
                NewUserDTO.builder()
                        .username(username)
                        .email(email)
                        .password(TEST_PASSWORD)
                        .type(UserType.PERSONAL)
                        .build();

        // When & Then
        assertDoesNotThrow(() -> authService.addUser(newUserDTO));

        // Verificar que el usuario fue creado en la base de datos
        User savedUser = slaveUserRepository.findByEmail(email).orElse(null);
        assertThat(savedUser).isNotNull();
        assertThat(savedUser.getUsername()).isEqualTo(username);
        assertThat(savedUser.getEmail()).isEqualTo(email);
        assertThat(savedUser.getType()).isEqualTo(UserType.PERSONAL);
        assertThat(savedUser.getState()).isEqualTo(State.PENDING);
        assertThat(passwordEncoder.matches(TEST_PASSWORD, savedUser.getPassword())).isTrue();
    }

    @Test
    @Order(2)
    @DisplayName("Debe fallar al registrar un usuario con email duplicado")
    void testUserRegistration_DuplicateEmail() {
        // Given
        User existingUser = createTestUser();

        NewUserDTO duplicateUserDTO =
                NewUserDTO.builder()
                        .username("anotheruser")
                        .email(existingUser.getEmail()) // Email duplicado
                        .password(TEST_PASSWORD)
                        .type(UserType.PERSONAL)
                        .build();

        // When & Then
        AuthException exception =
                assertThrows(AuthException.class, () -> authService.addUser(duplicateUserDTO));

        assertThat(exception.getMessage())
                .contains("correo con caracteres no permitidos o ya existente");
    }

    @Test
    @Order(3)
    @DisplayName("Debe activar una cuenta de usuario correctamente")
    void testUserActivation_Success() {
        // Given
        User testUser = createTestUser();
        assertThat(testUser.getState()).isEqualTo(State.PENDING);

        // When
        assertDoesNotThrow(() -> authService.activateUser(testUser.getEmail()));

        // Then
        User activatedUser = slaveUserRepository.findByEmail(testUser.getEmail()).orElse(null);
        assertThat(activatedUser).isNotNull();
        assertThat(activatedUser.getState()).isEqualTo(State.ACTIVE);
    }

    @Test
    @Order(4)
    @DisplayName("Debe autenticar un usuario exitosamente")
    void testAuthentication_Success() {
        // Given
        User testUser = createActiveTestUser();

        LoginDTO loginDTO =
                LoginDTO.builder().nameOrEmail(testUser.getEmail()).password(TEST_PASSWORD).build();

        MockHttpServletResponse response = new MockHttpServletResponse();

        // When
        TokenResponseDTO tokenResponse = authService.authenticate(loginDTO, response);

        // Then
        assertThat(tokenResponse).isNotNull();
        assertThat(tokenResponse.getToken()).isNotBlank();
        assertThat(tokenResponse.getType()).isEqualTo(UserType.PERSONAL.name());
    }

    @Test
    @Order(5)
    @DisplayName("Debe fallar la autenticación con cuenta no activada")
    void testAuthentication_InactiveAccount() {
        // Given
        User testUser = createTestUser(); // Usuario en estado PENDING

        LoginDTO loginDTO =
                LoginDTO.builder().nameOrEmail(testUser.getEmail()).password(TEST_PASSWORD).build();

        MockHttpServletResponse response = new MockHttpServletResponse();

        // When & Then
        AuthException exception =
                assertThrows(
                        AuthException.class, () -> authService.authenticate(loginDTO, response));

        assertThat(exception.getMessage())
                .contains("Credenciales Invalidas, verifique sus datos e intente nuevamente");
    }

    @Test
    @Order(6)
    @DisplayName("Debe cambiar la contraseña exitosamente")
    void testChangePassword_Success() {
        // Given
        User testUser = createActiveTestUser();
        String newPassword = "NewPassword456@";

        ChangePasswordDTO changePasswordDTO =
                ChangePasswordDTO.builder()
                        .email(testUser.getEmail())
                        .code("123456") // Código de verificación requerido
                        .newPassword(newPassword)
                        .build();

        // When
        String result = authService.changePasswordWithVerification(changePasswordDTO);

        // Then
        assertThat(result).isEqualTo("Contraseña actualizada correctamente");

        User updatedUser = slaveUserRepository.findByEmail(testUser.getEmail()).orElse(null);
        assertThat(updatedUser).isNotNull();
        assertThat(passwordEncoder.matches(newPassword, updatedUser.getPassword())).isTrue();
        assertThat(passwordEncoder.matches(TEST_PASSWORD, updatedUser.getPassword())).isFalse();
    }

    @Test
    @Order(7)
    @DisplayName("Endpoint de login debe devolver token JWT válido")
    void testLoginEndpoint_Success() throws Exception {
        // Given
        User testUser = createActiveTestUser();

        LoginDTO loginDTO =
                LoginDTO.builder().nameOrEmail(testUser.getEmail()).password(TEST_PASSWORD).build();

        // When
        MvcResult result =
                mockMvc.perform(
                                post("/v1/auth/login")
                                        .contentType(MediaType.APPLICATION_JSON)
                                        .content(objectMapper.writeValueAsString(loginDTO)))
                        .andExpect(status().isOk())
                        .andExpect(jsonPath("$.success").value(true))
                        .andExpect(jsonPath("$.data.token").isNotEmpty())
                        .andExpect(jsonPath("$.data.type").value("PERSONAL"))
                        .andReturn();

        // Then
        String responseBody = result.getResponse().getContentAsString();
        assertThat(responseBody).contains("Inicio de Sesión exitoso");
        assertThat(responseBody).contains("token");
    }

    @Test
    @Order(8)
    @DisplayName("Endpoint de registro debe crear usuario y enviar email de verificación")
    void testRegisterEndpoint_Success() throws Exception {
        // Given
        String email = getCurrentTestEmail();
        String username = getCurrentTestUsername();

        NewUserDTO newUserDTO =
                NewUserDTO.builder()
                        .username(username)
                        .email(email)
                        .password(TEST_PASSWORD)
                        .type(UserType.PERSONAL)
                        .build();

        // When
        mockMvc.perform(
                        post("/v1/auth/register")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(newUserDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(
                        jsonPath("$.message")
                                .value(
                                        "Registro exitoso. Código de verificación enviado al correo"));

        // Then - Verificar que el usuario fue creado
        User savedUser = slaveUserRepository.findByEmail(email).orElse(null);
        assertThat(savedUser).isNotNull();
        assertThat(savedUser.getState()).isEqualTo(State.PENDING);
    }

    @Test
    @Order(9)
    @DisplayName("Debe fallar el login con credenciales incorrectas")
    void testLogin_InvalidCredentials() throws Exception {
        // Given
        User testUser = createActiveTestUser();

        LoginDTO loginDTO =
                LoginDTO.builder()
                        .nameOrEmail(testUser.getEmail())
                        .password("WrongPassword123@")
                        .build();

        // When & Then
        mockMvc.perform(
                        post("/v1/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(loginDTO)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @Order(10)
    @DisplayName("Debe fallar el registro con datos inválidos")
    void testRegister_InvalidData() throws Exception {
        // Given
        NewUserDTO invalidUserDTO =
                NewUserDTO.builder()
                        .username("") // Username vacío
                        .email("invalid-email") // Email inválido
                        .password("123") // Password muy corta
                        .type(UserType.PERSONAL)
                        .build();

        // When & Then
        mockMvc.perform(
                        post("/v1/auth/register")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(invalidUserDTO)))
                .andExpect(status().isBadRequest());
    }

    // Métodos auxiliares para crear datos de prueba con datos únicos
    private User createTestUser() {
        String email = getCurrentTestEmail();
        String username = getCurrentTestUsername();

        return transactionTemplate.execute(
                status -> {
                    User user =
                            User.builder()
                                    .username(username)
                                    .email(email)
                                    .password(passwordEncoder.encode(TEST_PASSWORD))
                                    .type(UserType.PERSONAL)
                                    .state(State.PENDING)
                                    .version(0)
                                    .build();

                    // Asignar rol por defecto (simulando lo que hace el servicio real)
                    user.setRole(
                            slaveRoleRepository
                                    .findByName(RoleList.ROLE_USER)
                                    .orElseThrow(() -> new RuntimeException("Role not found")));

                    User savedUser = masterUserRepository.save(user);
                    masterUserRepository.flush();
                    return savedUser;
                });
    }

    private User createActiveTestUser() {
        String email = getCurrentTestEmail();
        String username = getCurrentTestUsername();

        return transactionTemplate.execute(
                status -> {
                    User user =
                            User.builder()
                                    .username(username)
                                    .email(email)
                                    .password(passwordEncoder.encode(TEST_PASSWORD))
                                    .type(UserType.PERSONAL)
                                    .state(State.ACTIVE) // Directamente ACTIVE
                                    .version(0)
                                    .build();

                    // Asignar rol por defecto (simulando lo que hace el servicio real)
                    user.setRole(
                            slaveRoleRepository
                                    .findByName(RoleList.ROLE_USER)
                                    .orElseThrow(() -> new RuntimeException("Role not found")));

                    User savedUser = masterUserRepository.save(user);
                    masterUserRepository.flush();
                    return savedUser;
                });
    }

    private User createTestUserWithEmailAndUsername(String email, String username) {
        return transactionTemplate.execute(
                status -> {
                    User user =
                            User.builder()
                                    .username(username)
                                    .email(email)
                                    .password(passwordEncoder.encode(TEST_PASSWORD))
                                    .type(UserType.PERSONAL)
                                    .state(State.PENDING)
                                    .version(0)
                                    .build();

                    // Asignar rol por defecto (simulando lo que hace el servicio real)
                    user.setRole(
                            slaveRoleRepository
                                    .findByName(RoleList.ROLE_USER)
                                    .orElseThrow(() -> new RuntimeException("Role not found")));

                    User savedUser = masterUserRepository.save(user);
                    masterUserRepository.flush();
                    return savedUser;
                });
    }

    private User createActiveTestUserWithEmailAndUsername(String email, String username) {
        return transactionTemplate.execute(
                status -> {
                    User user =
                            User.builder()
                                    .username(username)
                                    .email(email)
                                    .password(passwordEncoder.encode(TEST_PASSWORD))
                                    .type(UserType.PERSONAL)
                                    .state(State.ACTIVE)
                                    .version(0)
                                    .build();

                    // Asignar rol por defecto (simulando lo que hace el servicio real)
                    user.setRole(
                            slaveRoleRepository
                                    .findByName(RoleList.ROLE_USER)
                                    .orElseThrow(() -> new RuntimeException("Role not found")));

                    User savedUser = masterUserRepository.save(user);
                    masterUserRepository.flush();
                    return savedUser;
                });
    }
}
