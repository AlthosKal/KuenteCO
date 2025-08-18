package org.kuenteco.backend.service.auth;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.kuenteco.backend.config.jwt.JwtUtil;
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.entity.Role;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.AuthException;
import org.kuenteco.backend.mapper.auth.NewUserMapper;
import org.kuenteco.backend.repository.master.MasterRoleRepository;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveRoleRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.user.SendgridService;
import org.kuenteco.backend.service.user.UserService;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionTemplate;

@ExtendWith(MockitoExtension.class)
@DisplayName("AuthServiceImpl Unit Tests")
class AuthServiceImplTest {

    @InjectMocks private AuthServiceImpl authService;

    @Mock private PasswordEncoder passwordEncoder;
    @Mock private JwtUtil jwtUtil;
    @Mock private AuthenticationManagerBuilder authenticationManagerBuilder;
    @Mock private CookieService cookieService;
    @Mock private UserService userService;
    @Mock private MasterRoleRepository masterRoleRepository;
    @Mock private SlaveRoleRepository slaveRoleRepository;
    @Mock private MasterUserRepository masterUserRepository;
    @Mock private SlaveUserRepository slaveUserRepository;
    @Mock private TokenBlacklistService tokenBlacklistService;
    @Mock private TransactionTemplate transactionTemplate;
    @Mock private NewUserMapper newUserMapper;
    @Mock private SendgridService sendgridService;
    @Mock private MasterSubscriptionRepository masterSubscriptionRepository;
    @Mock private AuthenticationManager authenticationManager;
    @Mock private Authentication authentication;
    @Mock private HttpServletRequest httpServletRequest;
    @Mock private HttpServletResponse httpServletResponse;

    private User testUser;
    private Role testRole;
    private NewUserDTO newUserDTO;
    private LoginDTO loginDTO;

    @BeforeEach
    void setUp() {
        // Setup test data
        testRole = new Role();
        testRole.setId(1);
        testRole.setName(RoleList.ROLE_USER);

        testUser = new User();
        testUser.setId("test-user-id");
        testUser.setUsername("testuser");
        testUser.setEmail("test@kuenteco.com");
        testUser.setPassword("encoded-password");
        testUser.setRole(testRole);
        testUser.setState(State.ACTIVE);
        testUser.setType(UserType.PERSONAL);
        testUser.setVersion(0);

        newUserDTO = new NewUserDTO();
        newUserDTO.setUsername("newuser");
        newUserDTO.setEmail("newuser@kuenteco.com");
        newUserDTO.setPassword("password123");
        newUserDTO.setType(UserType.PERSONAL);

        loginDTO = new LoginDTO();
        loginDTO.setNameOrEmail("test@kuenteco.com");
        loginDTO.setPassword("password123");
    }

    @Test
    @DisplayName("Should authenticate user successfully")
    void shouldAuthenticateUserSuccessfully() {
        // Given
        String expectedToken = "jwt-token-123";

        when(userService.findByNameOrEmail("test@kuenteco.com")).thenReturn(testUser);
        when(authenticationManagerBuilder.getObject()).thenReturn(authenticationManager);
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(authentication);
        when(jwtUtil.generateToken(authentication)).thenReturn(expectedToken);

        // When
        TokenResponseDTO result = authService.authenticate(loginDTO, httpServletResponse);

        // Then
        assertNotNull(result);
        assertEquals(expectedToken, result.getToken());
        assertEquals(UserType.PERSONAL, result.getType());

        verify(cookieService)
                .addHttpOnlyCookie(
                        eq("jwt"),
                        eq(expectedToken),
                        eq(7 * 24 * 60 * 60),
                        eq(httpServletResponse));
        verify(userService).findByNameOrEmail("test@kuenteco.com");
        verify(authenticationManager).authenticate(any(UsernamePasswordAuthenticationToken.class));
    }

    @Test
    @DisplayName("Should throw exception when user is not active")
    void shouldThrowExceptionWhenUserIsNotActive() {
        // Given
        testUser.setState(State.PENDING);
        when(userService.findByNameOrEmail("test@kuenteco.com")).thenReturn(testUser);

        // When & Then
        AuthException exception =
                assertThrows(
                        AuthException.class,
                        () -> {
                            authService.authenticate(loginDTO, httpServletResponse);
                        });

        assertEquals("Cuenta no activada, Por favor verifica tu correo", exception.getMessage());
        verify(authenticationManager, never()).authenticate(any());
    }

    @Test
    @DisplayName("Should throw exception when user not found")
    void shouldThrowExceptionWhenUserNotFound() {
        // Given
        when(userService.findByNameOrEmail("nonexistent@kuenteco.com")).thenReturn(null);
        loginDTO.setNameOrEmail("nonexistent@kuenteco.com");

        // When & Then
        AuthException exception =
                assertThrows(
                        AuthException.class,
                        () -> {
                            authService.authenticate(loginDTO, httpServletResponse);
                        });

        assertEquals("Cuenta no activada, Por favor verifica tu correo", exception.getMessage());
    }

    @Test
    @DisplayName("Should add new user successfully")
    void shouldAddNewUserSuccessfully() {
        // Given
        when(userService.existsByUserName("newuser")).thenReturn(false);
        when(userService.existsByUserEmail("newuser@kuenteco.com")).thenReturn(false);
        when(slaveRoleRepository.findByName(RoleList.ROLE_USER)).thenReturn(Optional.of(testRole));
        when(newUserMapper.toEntity(newUserDTO)).thenReturn(testUser);
        when(passwordEncoder.encode("password123")).thenReturn("encoded-password");
        when(masterUserRepository.save(any(User.class))).thenReturn(testUser);
        when(masterSubscriptionRepository.save(any(Subscription.class)))
                .thenReturn(new Subscription());

        // Configure transaction template to execute the lambda
        when(transactionTemplate.execute(any()))
                .thenAnswer(
                        invocation -> {
                            TransactionCallback<?> callback = invocation.getArgument(0);
                            return callback.doInTransaction(null);
                        });

        // When
        authService.addUser(newUserDTO);

        // Then
        verify(userService).existsByUserName("newuser");
        verify(userService).existsByUserEmail("newuser@kuenteco.com");
        verify(passwordEncoder).encode("password123");
        verify(masterUserRepository).save(any(User.class));
        verify(masterSubscriptionRepository).save(any(Subscription.class));
        verify(sendgridService).sendVerificationEmail(any(SendVerificationCodeDTO.class), eq(true));
    }

    @Test
    @DisplayName("Should throw exception when username already exists")
    void shouldThrowExceptionWhenUsernameAlreadyExists() {
        // Given
        when(userService.existsByUserName("newuser")).thenReturn(true);

        // When & Then
        AuthException exception =
                assertThrows(
                        AuthException.class,
                        () -> {
                            authService.addUser(newUserDTO);
                        });

        assertEquals(
                "Datos Inválidos, nombre con caracteres no permitidos o ya existente",
                exception.getMessage());
        verify(masterUserRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should throw exception when email already exists")
    void shouldThrowExceptionWhenEmailAlreadyExists() {
        // Given
        when(userService.existsByUserName("newuser")).thenReturn(false);
        when(userService.existsByUserEmail("newuser@kuenteco.com")).thenReturn(true);

        // When & Then
        AuthException exception =
                assertThrows(
                        AuthException.class,
                        () -> {
                            authService.addUser(newUserDTO);
                        });

        assertEquals(
                "Datos Inválidos, correo con caracteres no permitidos o ya existente",
                exception.getMessage());
        verify(masterUserRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should activate user successfully")
    void shouldActivateUserSuccessfully() {
        // Given
        testUser.setState(State.PENDING);
        when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                .thenReturn(Optional.of(testUser));
        when(masterUserRepository.save(testUser)).thenReturn(testUser);

        // Configure transaction template to execute the lambda
        when(transactionTemplate.execute(any()))
                .thenAnswer(
                        invocation -> {
                            TransactionCallback<?> callback = invocation.getArgument(0);
                            return callback.doInTransaction(null);
                        });

        // When
        authService.activateUser("test@kuenteco.com");

        // Then
        assertEquals(State.ACTIVE, testUser.getState());
        verify(masterUserRepository).save(testUser);
    }

    @Test
    @DisplayName("Should handle already activated user gracefully")
    void shouldHandleAlreadyActivatedUserGracefully() {
        // Given - User is already active
        testUser.setState(State.ACTIVE);
        when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                .thenReturn(Optional.of(testUser));

        // Configure transaction template to return true
        when(transactionTemplate.execute(any()))
                .thenAnswer(
                        invocation -> {
                            TransactionCallback<?> callback = invocation.getArgument(0);
                            return callback.doInTransaction(null);
                        });

        // When & Then - Should not throw exception
        assertDoesNotThrow(
                () -> {
                    authService.activateUser("test@kuenteco.com");
                });

        // User state should remain active
        assertEquals(State.ACTIVE, testUser.getState());
    }

    @Test
    @DisplayName("Should throw exception when activating non-existent user")
    void shouldThrowExceptionWhenActivatingNonExistentUser() {
        // Given
        when(slaveUserRepository.findByEmail("nonexistent@kuenteco.com"))
                .thenReturn(Optional.empty());
        when(transactionTemplate.execute(any()))
                .thenAnswer(
                        invocation -> {
                            TransactionCallback<?> callback = invocation.getArgument(0);
                            try {
                                return callback.doInTransaction(null);
                            } catch (AuthException e) {
                                throw e;
                            }
                        });

        // When & Then
        assertThrows(
                AuthException.class,
                () -> {
                    authService.activateUser("nonexistent@kuenteco.com");
                });
    }

    @Test
    @DisplayName("Should change password successfully")
    void shouldChangePasswordSuccessfully() {
        // Given
        ChangePasswordDTO changePasswordDTO = new ChangePasswordDTO();
        changePasswordDTO.setEmail("test@kuenteco.com");
        changePasswordDTO.setCode("verification-code-123");
        changePasswordDTO.setNewPassword("newPassword123");

        when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                .thenReturn(Optional.of(testUser));
        when(passwordEncoder.encode("newPassword123")).thenReturn("new-encoded-password");
        when(masterUserRepository.save(testUser)).thenReturn(testUser);

        // Configure transaction template
        when(transactionTemplate.execute(any()))
                .thenAnswer(
                        invocation -> {
                            TransactionCallback<?> callback = invocation.getArgument(0);
                            return callback.doInTransaction(null);
                        });

        // When
        String result = authService.changePasswordWithVerification(changePasswordDTO);

        // Then
        assertEquals("Contraseña actualizada correctamente", result);
        assertEquals("new-encoded-password", testUser.getPassword());
        verify(passwordEncoder).encode("newPassword123");
        verify(masterUserRepository).save(testUser);
    }

    @Test
    @DisplayName("Should throw exception when changing password for inactive account")
    void shouldThrowExceptionWhenChangingPasswordForInactiveAccount() {
        // Given
        testUser.setState(State.PENDING);
        ChangePasswordDTO changePasswordDTO = new ChangePasswordDTO();
        changePasswordDTO.setEmail("test@kuenteco.com");
        changePasswordDTO.setNewPassword("newPassword123");

        when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                .thenReturn(Optional.of(testUser));
        when(transactionTemplate.execute(any()))
                .thenAnswer(
                        invocation -> {
                            TransactionCallback<?> callback = invocation.getArgument(0);
                            try {
                                return callback.doInTransaction(null);
                            } catch (RuntimeException e) {
                                throw e;
                            }
                        });

        // When & Then
        assertThrows(
                RuntimeException.class,
                () -> {
                    authService.changePasswordWithVerification(changePasswordDTO);
                });

        verify(passwordEncoder, never()).encode(anyString());
        verify(masterUserRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should logout successfully")
    void shouldLogoutSuccessfully() {
        // Given
        String token = "jwt-token-123";
        when(jwtUtil.resolveToken(httpServletRequest)).thenReturn(token);

        // When
        authService.logout(httpServletRequest, httpServletResponse);

        // Then
        verify(tokenBlacklistService).addToBlacklist(token);
        verify(cookieService).deleteCookie("jwt", httpServletResponse);
    }

    @Test
    @DisplayName("Should throw exception when logout without token")
    void shouldThrowExceptionWhenLogoutWithoutToken() {
        // Given
        when(jwtUtil.resolveToken(httpServletRequest)).thenReturn(null);

        // When & Then
        AuthException exception =
                assertThrows(
                        AuthException.class,
                        () -> {
                            authService.logout(httpServletRequest, httpServletResponse);
                        });

        assertEquals("Token no proporcionado", exception.getMessage());
        verify(tokenBlacklistService, never()).addToBlacklist(anyString());
        verify(cookieService, never()).deleteCookie(anyString(), any());
    }

    @Test
    @DisplayName("Should validate role assignment during user registration")
    void shouldValidateRoleAssignmentDuringUserRegistration() {
        // Test that role assignment works correctly during user creation

        // Given
        when(userService.existsByUserName("roletest")).thenReturn(false);
        when(userService.existsByUserEmail("roletest@kuenteco.com")).thenReturn(false);
        when(slaveRoleRepository.findByName(RoleList.ROLE_USER)).thenReturn(Optional.of(testRole));
        when(newUserMapper.toEntity(any())).thenReturn(testUser);
        when(passwordEncoder.encode("password")).thenReturn("encoded");
        when(masterUserRepository.save(any())).thenReturn(testUser);
        when(masterSubscriptionRepository.save(any(Subscription.class)))
                .thenReturn(new Subscription());

        // Configure transaction template
        when(transactionTemplate.execute(any()))
                .thenAnswer(
                        invocation -> {
                            TransactionCallback<?> callback = invocation.getArgument(0);
                            return callback.doInTransaction(null);
                        });

        NewUserDTO roleTestDTO = new NewUserDTO();
        roleTestDTO.setUsername("roletest");
        roleTestDTO.setEmail("roletest@kuenteco.com");
        roleTestDTO.setPassword("password");
        roleTestDTO.setType(UserType.BUSINESS);

        // When
        authService.addUser(roleTestDTO);

        // Then
        verify(slaveRoleRepository).findByName(RoleList.ROLE_USER);
        verify(masterUserRepository).save(any(User.class));
        verify(masterSubscriptionRepository).save(any(Subscription.class));
    }

    @Test
    @DisplayName("Should handle subscription creation during user registration")
    void shouldHandleSubscriptionCreationDuringUserRegistration() {
        // Given
        when(userService.existsByUserName("subtest")).thenReturn(false);
        when(userService.existsByUserEmail("subtest@kuenteco.com")).thenReturn(false);
        when(slaveRoleRepository.findByName(RoleList.ROLE_USER)).thenReturn(Optional.of(testRole));
        when(newUserMapper.toEntity(any())).thenReturn(testUser);
        when(passwordEncoder.encode(any())).thenReturn("encoded");
        when(masterUserRepository.save(any())).thenReturn(testUser);
        when(masterSubscriptionRepository.save(any(Subscription.class)))
                .thenReturn(new Subscription());

        // Configure transaction template
        when(transactionTemplate.execute(any()))
                .thenAnswer(
                        invocation -> {
                            TransactionCallback<?> callback = invocation.getArgument(0);
                            return callback.doInTransaction(null);
                        });

        NewUserDTO subTestDTO = new NewUserDTO();
        subTestDTO.setUsername("subtest");
        subTestDTO.setEmail("subtest@kuenteco.com");
        subTestDTO.setPassword("password");
        subTestDTO.setType(UserType.PERSONAL);

        // When
        authService.addUser(subTestDTO);

        // Then
        verify(masterSubscriptionRepository)
                .save(
                        argThat(
                                subscription ->
                                        subscription.getState() == State.INACTIVE
                                                && subscription.getType() == SubscriptionType.BASIC
                                                && subscription.getUser() != null));
    }

    @Test
    @DisplayName("Should validate authentication manager interaction")
    void shouldValidateAuthenticationManagerInteraction() {
        // Test that the authentication manager is called correctly

        // Given
        String expectedToken = "generated-jwt-token";
        when(userService.findByNameOrEmail("test@kuenteco.com")).thenReturn(testUser);
        when(authenticationManagerBuilder.getObject()).thenReturn(authenticationManager);
        when(authenticationManager.authenticate(any())).thenReturn(authentication);
        when(jwtUtil.generateToken(any(Authentication.class))).thenReturn(expectedToken);

        // When
        TokenResponseDTO result = authService.authenticate(loginDTO, httpServletResponse);

        // Then
        assertNotNull(result);
        assertEquals(expectedToken, result.getToken());
        assertEquals(UserType.PERSONAL, result.getType());

        // Verify authentication manager was called
        verify(authenticationManager).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(cookieService)
                .addHttpOnlyCookie(
                        eq("jwt"),
                        eq(expectedToken),
                        eq(7 * 24 * 60 * 60),
                        eq(httpServletResponse));
    }
}
