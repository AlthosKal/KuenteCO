package org.kuenteco.backend.service.logic.budget;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.math.BigDecimal;
import java.util.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.logic.budget.*;
import org.kuenteco.backend.entity.Budget;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.BudgetException;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.budget.BudgetDetailMapper;
import org.kuenteco.backend.mapper.logic.budget.NewBudgetMapper;
import org.kuenteco.backend.mapper.logic.budget.UpdateBudgetMapper;
import org.kuenteco.backend.repository.master.MasterBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
@DisplayName("BudgetServiceImpl Unit Tests")
class BudgetServiceImplTest {

    @InjectMocks private BudgetServiceImpl budgetService;

    @Mock private MasterBudgetRepository masterBudgetRepository;
    @Mock private SlaveBudgetRepository slaveBudgetRepository;
    @Mock private SlaveUserRepository slaveUserRepository;
    @Mock private BudgetDetailMapper budgetDetailMapper;
    @Mock private UpdateBudgetMapper updateBudgetMapper;
    @Mock private NewBudgetMapper newBudgetMapper;

    private User testUser;
    private Budget testBudget;
    private NewBudgetDTO newBudgetDTO;
    private BudgetDTO budgetDTO;

    @BeforeEach
    void setUp() {
        // Setup test user
        testUser = new User();
        testUser.setId("test-user-id");
        testUser.setEmail("test@kuenteco.com");
        testUser.setUsername("testuser");
        testUser.setType(UserType.PERSONAL);

        // Setup test budget
        testBudget = new Budget();
        testBudget.setId(1);
        testBudget.setName("Test Budget");
        testBudget.setTotalBudget(new BigDecimal("5000.00"));
        testBudget.setRemainingBudget(new BigDecimal("3000.00"));
        testBudget.setUser(testUser);

        // Setup DTOs
        newBudgetDTO = new NewBudgetDTO();
        newBudgetDTO.setName("New Budget");
        newBudgetDTO.setTotalBudget(new BigDecimal("2000.00"));

        budgetDTO = new BudgetDTO();
        budgetDTO.setId(1);
        budgetDTO.setName("Updated Budget");
        budgetDTO.setTotalBudget(new BigDecimal("2500.00"));
    }

    @Test
    @DisplayName("Should get budgets successfully for user")
    void shouldGetBudgetsSuccessfullyForUser() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<Budget> budgets = Arrays.asList(testBudget);
        List<BudgetDTO> budgetDTOs = Arrays.asList(new BudgetDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveBudgetRepository.findByUser(testUser)).thenReturn(budgets);
            when(budgetDetailMapper.toDtoList(budgets)).thenReturn(budgetDTOs);

            // When
            Object result = budgetService.getBudgets();

            // Then
            assertNotNull(result);
            assertEquals(budgetDTOs, result);
            verify(slaveBudgetRepository).findByUser(testUser);
            verify(budgetDetailMapper).toDtoList(budgets);
        }
    }

    @Test
    @DisplayName("Should return message when user has no budgets")
    void shouldReturnMessageWhenUserHasNoBudgets() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveBudgetRepository.findByUser(testUser)).thenReturn(Collections.emptyList());

            // When
            Object result = budgetService.getBudgets();

            // Then
            assertEquals("No tienes presupuestos registrados", result);
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to get budgets")
    void shouldThrowExceptionWhenProfileTriesToGetBudgets() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            BudgetException exception =
                    assertThrows(
                            BudgetException.class,
                            () -> {
                                budgetService.getBudgets();
                            });

            assertEquals("Endpoint solo disponible para usuarios", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should throw exception when user not found for budgets")
    void shouldThrowExceptionWhenUserNotFoundForBudgets() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("nonexistent@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("nonexistent@kuenteco.com"))
                    .thenReturn(Optional.empty());

            // When & Then
            CategoryException exception =
                    assertThrows(
                            CategoryException.class,
                            () -> {
                                budgetService.getBudgets();
                            });

            assertTrue(exception.getMessage().contains("Usuario no encontrado"));
        }
    }

    @Test
    @DisplayName("Should get budget vs actual report successfully")
    void shouldGetBudgetVsActualReportSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<BudgetVsActualDTO> reportDTOs = Arrays.asList(new BudgetVsActualDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveBudgetRepository.findAllBudgetVsActual("test@kuenteco.com"))
                    .thenReturn(reportDTOs);

            // When
            Object result = budgetService.getBudgetVsActualReport();

            // Then
            assertEquals(reportDTOs, result);
            verify(slaveBudgetRepository).findAllBudgetVsActual("test@kuenteco.com");
        }
    }

    @Test
    @DisplayName("Should return message when no budget vs actual data found")
    void shouldReturnMessageWhenNoBudgetVsActualDataFound() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveBudgetRepository.findAllBudgetVsActual("test@kuenteco.com"))
                    .thenReturn(Collections.emptyList());

            // When
            Object result = budgetService.getBudgetVsActualReport();

            // Then
            assertEquals("No tienes presupuestos registrados", result);
        }
    }

    @Test
    @DisplayName("Should get budget summary successfully")
    void shouldGetBudgetSummarySuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<BudgetSummaryDTO> summaryDTOs = Arrays.asList(new BudgetSummaryDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveBudgetRepository.getBudgetSummaries("test@kuenteco.com"))
                    .thenReturn(summaryDTOs);

            // When
            Object result = budgetService.getBudgetSummary();

            // Then
            assertEquals(summaryDTOs, result);
            verify(slaveBudgetRepository).getBudgetSummaries("test@kuenteco.com");
        }
    }

    @Test
    @DisplayName("Should return message when no budget summary data found")
    void shouldReturnMessageWhenNoBudgetSummaryDataFound() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveBudgetRepository.getBudgetSummaries("test@kuenteco.com"))
                    .thenReturn(Collections.emptyList());

            // When
            Object result = budgetService.getBudgetSummary();

            // Then
            assertEquals("No tienes presupuestos registrados", result);
        }
    }

    @Test
    @DisplayName("Should add budget successfully")
    void shouldAddBudgetSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Budget newBudget = new Budget();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newBudgetMapper.toEntity(newBudgetDTO)).thenReturn(newBudget);

            // When
            budgetService.addBudget(newBudgetDTO);

            // Then
            verify(newBudgetMapper).toEntity(newBudgetDTO);
            verify(masterBudgetRepository)
                    .save(argThat(budget -> budget.getUser().equals(testUser)));
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to add budget")
    void shouldThrowExceptionWhenProfileTriesToAddBudget() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            BudgetException exception =
                    assertThrows(
                            BudgetException.class,
                            () -> {
                                budgetService.addBudget(newBudgetDTO);
                            });

            assertEquals("Endpoint solo disponible para usuarios", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should throw exception when user not found for add budget")
    void shouldThrowExceptionWhenUserNotFoundForAddBudget() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("nonexistent@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("nonexistent@kuenteco.com"))
                    .thenReturn(Optional.empty());

            // When & Then
            BudgetException exception =
                    assertThrows(
                            BudgetException.class,
                            () -> {
                                budgetService.addBudget(newBudgetDTO);
                            });

            assertTrue(exception.getMessage().contains("Usuario no encontrado"));
        }
    }

    @Test
    @DisplayName("Should update budget successfully")
    void shouldUpdateBudgetSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        budgetDTO.setId(1);
        budgetDTO.setName("Test Budget");
        budgetDTO.setTotalBudget(new BigDecimal("5000.00"));

        // Este será el Budget que devuelva el mapper (con valores seteados)
        Budget updatedBudget = new Budget();
        updatedBudget.setName("Test Budget");
        updatedBudget.setTotalBudget(new BigDecimal("5000.00"));

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {

            authService
                    .when(org.kuenteco.backend.service.auth.AuthServiceImpl::getCredentials)
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveBudgetRepository.getBudgetByUserAndId(testUser, 1))
                    .thenReturn(Optional.of(testBudget));
            when(updateBudgetMapper.toEntity(budgetDTO)).thenReturn(updatedBudget);

            // When
            budgetService.updateBudget(budgetDTO);

            // Then
            verify(updateBudgetMapper).toEntity(budgetDTO);
            verify(slaveBudgetRepository).getBudgetByUserAndId(testUser, 1);

            // Verificamos por propiedades en vez de la instancia
            verify(masterBudgetRepository)
                    .save(
                            argThat(
                                    b ->
                                            b != null
                                                    && b.getUser().equals(testUser)
                                                    && Objects.equals(b.getName(), "Test Budget")
                                                    && b.getTotalBudget()
                                                                    .compareTo(
                                                                            new BigDecimal(
                                                                                    "5000.00"))
                                                            == 0));
        }
    }

    @Test
    @DisplayName("Should throw exception when budget not found for update")
    void shouldThrowExceptionWhenBudgetNotFoundForUpdate() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveBudgetRepository.getBudgetByUserAndId(testUser, 1))
                    .thenReturn(Optional.empty());

            // When & Then
            BudgetException exception =
                    assertThrows(
                            BudgetException.class,
                            () -> {
                                budgetService.updateBudget(budgetDTO);
                            });

            assertEquals("Presupuesto no encontrado", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should delete budget successfully")
    void shouldDeleteBudgetSuccessfully() {
        // Given
        Integer budgetId = 1;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveBudgetRepository.existsById(budgetId)).thenReturn(true);

            // When
            budgetService.deleteBudget(budgetId);

            // Then
            verify(masterBudgetRepository).deleteById(budgetId);
        }
    }

    @Test
    @DisplayName("Should throw exception when deleting non-existent budget")
    void shouldThrowExceptionWhenDeletingNonExistentBudget() {
        // Given
        Integer budgetId = 999;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveBudgetRepository.existsById(budgetId)).thenReturn(false);

            // When & Then
            BudgetException exception =
                    assertThrows(
                            BudgetException.class,
                            () -> {
                                budgetService.deleteBudget(budgetId);
                            });

            assertTrue(
                    exception
                            .getMessage()
                            .contains("ID del presupuesto no encontrado con el ID: 999"));
        }
    }

    @Test
    @DisplayName("Should throw exception when deleting budget with null ID")
    void shouldThrowExceptionWhenDeletingBudgetWithNullId() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            BudgetException exception =
                    assertThrows(
                            BudgetException.class,
                            () -> {
                                budgetService.deleteBudget(null);
                            });

            assertEquals("ID del presupuesto no puede ser nulo", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to get budget vs actual report")
    void shouldThrowExceptionWhenProfileTriesToGetBudgetVsActualReport() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            BudgetException exception =
                    assertThrows(
                            BudgetException.class,
                            () -> {
                                budgetService.getBudgetVsActualReport();
                            });

            assertEquals("Endpoint solo disponible para usuarios", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to get budget summary")
    void shouldThrowExceptionWhenProfileTriesToGetBudgetSummary() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            BudgetException exception =
                    assertThrows(
                            BudgetException.class,
                            () -> {
                                budgetService.getBudgetSummary();
                            });

            assertEquals("Endpoint solo disponible para usuarios", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should validate budget amount calculations")
    void shouldValidateBudgetAmountCalculations() {
        // Given
        NewBudgetDTO largeBudgetDTO = new NewBudgetDTO();
        largeBudgetDTO.setName("Large Budget");
        largeBudgetDTO.setTotalBudget(new BigDecimal("10000.50"));

        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Budget newBudget = new Budget();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newBudgetMapper.toEntity(largeBudgetDTO)).thenReturn(newBudget);

            // When
            budgetService.addBudget(largeBudgetDTO);

            // Then
            verify(masterBudgetRepository)
                    .save(argThat(budget -> budget.getUser().equals(testUser)));
            verify(newBudgetMapper)
                    .toEntity(
                            argThat(
                                    dto ->
                                            dto.getTotalBudget()
                                                            .compareTo(new BigDecimal("10000.50"))
                                                    == 0));
        }
    }

    @Test
    @DisplayName("Should handle zero budget amounts")
    void shouldHandleZeroBudgetAmounts() {
        // Given
        NewBudgetDTO zeroBudgetDTO = new NewBudgetDTO();
        zeroBudgetDTO.setName("Zero Budget");
        zeroBudgetDTO.setTotalBudget(BigDecimal.ZERO);

        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Budget newBudget = new Budget();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newBudgetMapper.toEntity(zeroBudgetDTO)).thenReturn(newBudget);

            // When
            budgetService.addBudget(zeroBudgetDTO);

            // Then
            verify(masterBudgetRepository).save(any(Budget.class));
            verify(newBudgetMapper)
                    .toEntity(argThat(dto -> dto.getTotalBudget().compareTo(BigDecimal.ZERO) == 0));
        }
    }

    @Test
    @DisplayName("Should validate budget update with different amounts")
    void shouldValidateBudgetUpdateWithDifferentAmounts() {
        // Given
        BudgetDTO increaseBudgetDTO = new BudgetDTO();
        increaseBudgetDTO.setId(1);
        increaseBudgetDTO.setName("Increased Budget");
        increaseBudgetDTO.setTotalBudget(new BigDecimal("7500.00"));

        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Budget updatedBudget = new Budget();
        updatedBudget.setName(increaseBudgetDTO.getName());
        updatedBudget.setTotalBudget(increaseBudgetDTO.getTotalBudget());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveBudgetRepository.getBudgetByUserAndId(testUser, 1))
                    .thenReturn(Optional.of(testBudget));
            when(updateBudgetMapper.toEntity(increaseBudgetDTO)).thenReturn(updatedBudget);

            // When
            budgetService.updateBudget(increaseBudgetDTO);

            // Then
            verify(updateBudgetMapper)
                    .toEntity(
                            argThat(
                                    dto ->
                                            dto.getTotalBudget()
                                                            .compareTo(new BigDecimal("7500.00"))
                                                    == 0));

            verify(masterBudgetRepository)
                    .save(
                            argThat(
                                    b ->
                                            b.getUser().equals(testUser)
                                                    && b.getName().equals("Increased Budget")
                                                    && b.getTotalBudget()
                                                                    .compareTo(
                                                                            new BigDecimal(
                                                                                    "7500.00"))
                                                            == 0));
        }
    }

    @Test
    @DisplayName("Should handle budget with special characters in name")
    void shouldHandleBudgetWithSpecialCharactersInName() {
        // Given
        NewBudgetDTO specialBudgetDTO = new NewBudgetDTO();
        specialBudgetDTO.setName("Budget-2024 (Q1) & [Emergency] 50%");
        specialBudgetDTO.setTotalBudget(new BigDecimal("1500.00"));

        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Budget newBudget = new Budget();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newBudgetMapper.toEntity(specialBudgetDTO)).thenReturn(newBudget);

            // When
            budgetService.addBudget(specialBudgetDTO);

            // Then
            verify(masterBudgetRepository).save(any(Budget.class));
            verify(newBudgetMapper)
                    .toEntity(
                            argThat(
                                    dto ->
                                            dto.getName()
                                                    .equals("Budget-2024 (Q1) & [Emergency] 50%")));
        }
    }

    @Test
    @DisplayName("Should validate role-based access control across all operations")
    void shouldValidateRoleBasedAccessControlAcrossAllOperations() {
        // Test that all operations properly reject ROLE_PROFILE
        AuthCredentials profileCredentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(profileCredentials);

            // Test getBudgets
            assertThrows(BudgetException.class, () -> budgetService.getBudgets());

            // Test getBudgetVsActualReport
            assertThrows(BudgetException.class, () -> budgetService.getBudgetVsActualReport());

            // Test getBudgetSummary
            assertThrows(BudgetException.class, () -> budgetService.getBudgetSummary());

            // Test addBudget
            assertThrows(BudgetException.class, () -> budgetService.addBudget(newBudgetDTO));

            // Test updateBudget
            assertThrows(BudgetException.class, () -> budgetService.updateBudget(budgetDTO));

            // Test deleteBudget
            assertThrows(BudgetException.class, () -> budgetService.deleteBudget(1));
        }
    }
}
