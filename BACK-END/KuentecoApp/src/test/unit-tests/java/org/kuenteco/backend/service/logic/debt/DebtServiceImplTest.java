package org.kuenteco.backend.service.logic.debt;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.logic.debt.*;
import org.kuenteco.backend.entity.Debt;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.StateDebt;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.DebtException;
import org.kuenteco.backend.mapper.logic.debt.DebtDetailMapper;
import org.kuenteco.backend.mapper.logic.debt.NewDebtMapper;
import org.kuenteco.backend.mapper.logic.debt.UpdateDebtMapper;
import org.kuenteco.backend.mapper.logic.debt.debtsByStateMapper;
import org.kuenteco.backend.repository.master.MasterDebtRepository;
import org.kuenteco.backend.repository.slave.SlaveDebtRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
@DisplayName("DebtServiceImpl Unit Tests")
class DebtServiceImplTest {

    @InjectMocks private DebtServiceImpl debtService;

    @Mock private MasterDebtRepository masterDebtRepository;
    @Mock private SlaveDebtRepository slaveDebtRepository;
    @Mock private SlaveUserRepository slaveUserRepository;
    @Mock private DebtDetailMapper debtDetailMapper;
    @Mock private debtsByStateMapper debtsByStateMapper;
    @Mock private NewDebtMapper newDebtMapper;
    @Mock private UpdateDebtMapper updateDebtMapper;

    private User testUser;
    private Debt testDebt;
    private NewDebtDTO newDebtDTO;
    private DebtPaymentDTO debtPaymentDTO;

    @BeforeEach
    void setUp() {
        // Setup test user
        testUser = new User();
        testUser.setId("test-user-id");
        testUser.setEmail("test@kuenteco.com");
        testUser.setUsername("testuser");
        testUser.setType(UserType.PERSONAL);

        // Setup test debt
        testDebt = new Debt();
        testDebt.setId(1);
        testDebt.setName("Test Debt");
        testDebt.setTotalAmount(new BigDecimal("5000.00"));
        testDebt.setPendingAmount(new BigDecimal("3000.00"));
        testDebt.setState(StateDebt.ACTIVE);
        testDebt.setUser(testUser);

        // Setup DTOs
        newDebtDTO = new NewDebtDTO();
        newDebtDTO.setName("New Debt");
        newDebtDTO.setTotalAmount(new BigDecimal("2000.00"));
        newDebtDTO.setPendingAmount(new BigDecimal("2000.00"));
        newDebtDTO.setStartDate(LocalDateTime.now());
        newDebtDTO.setExpirationDate(LocalDateTime.now().plusDays(30));

        debtPaymentDTO = new DebtPaymentDTO();
        debtPaymentDTO.setDebtId(1);
        debtPaymentDTO.setPaymentAmount(new BigDecimal("500.00"));
    }

    @Test
    @DisplayName("Should get debts successfully for user")
    void shouldGetDebtsSuccessfullyForUser() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<Debt> debts = Arrays.asList(testDebt);
        List<DebtDTO> debtDTOs = Arrays.asList(new DebtDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveDebtRepository.findByUser(testUser)).thenReturn(debts);
            when(debtDetailMapper.toDtoList(debts)).thenReturn(debtDTOs);

            // When
            Object result = debtService.getDebts();

            // Then
            assertNotNull(result);
            assertEquals(debtDTOs, result);
            verify(slaveDebtRepository).findByUser(testUser);
            verify(debtDetailMapper).toDtoList(debts);
        }
    }

    @Test
    @DisplayName("Should return message when user has no debts")
    void shouldReturnMessageWhenUserHasNoDebts() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveDebtRepository.findByUser(testUser)).thenReturn(Collections.emptyList());

            // When
            Object result = debtService.getDebts();

            // Then
            assertEquals("No tienes deudas registradas", result);
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to get debts")
    void shouldThrowExceptionWhenProfileTriesToGetDebts() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            DebtException exception =
                    assertThrows(
                            DebtException.class,
                            () -> {
                                debtService.getDebts();
                            });

            assertEquals("Endpoint solo disponible para usuarios", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should get debts by state successfully")
    void shouldGetDebtsByStateSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<Debt> debts = Arrays.asList(testDebt);
        List<DebtDTO> debtDTOs = Arrays.asList(new DebtDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveDebtRepository.findByStateAndUser(StateDebt.ACTIVE, testUser))
                    .thenReturn(debts);
            when(debtsByStateMapper.toDtoList(debts)).thenReturn(debtDTOs);

            // When
            Object result = debtService.getDebtsByState(StateDebt.ACTIVE);

            // Then
            assertEquals(debtDTOs, result);
            verify(slaveDebtRepository).findByStateAndUser(StateDebt.ACTIVE, testUser);
            verify(debtsByStateMapper).toDtoList(debts);
        }
    }

    @Test
    @DisplayName("Should get debt summary report successfully")
    void shouldGetDebtSummaryReportSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<DebtSummaryDTO> summaryDTOs = Arrays.asList(new DebtSummaryDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveDebtRepository.findByUserEmailDebtSummaries("test@kuenteco.com"))
                    .thenReturn(summaryDTOs);

            // When
            Object result = debtService.getDebtSummaryReport();

            // Then
            assertEquals(summaryDTOs, result);
            verify(slaveDebtRepository).findByUserEmailDebtSummaries("test@kuenteco.com");
        }
    }

    @Test
    @DisplayName("Should return message when no debt summary found")
    void shouldReturnMessageWhenNoDebtSummaryFound() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveDebtRepository.findByUserEmailDebtSummaries("test@kuenteco.com"))
                    .thenReturn(Collections.emptyList());

            // When
            Object result = debtService.getDebtSummaryReport();

            // Then
            assertEquals("No tienes deudas registradas", result);
        }
    }

    @Test
    @DisplayName("Should get total pending amount successfully")
    void shouldGetTotalPendingAmountSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        BigDecimal expectedTotal = new BigDecimal("3000.00");

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveDebtRepository.sumPendingAmountByStateAndUser(StateDebt.ACTIVE, testUser))
                    .thenReturn(expectedTotal);

            // When
            BigDecimal result = debtService.getTotalPendingAmount();

            // Then
            assertEquals(expectedTotal, result);
            verify(slaveDebtRepository).sumPendingAmountByStateAndUser(StateDebt.ACTIVE, testUser);
        }
    }

    @Test
    @DisplayName("Should return zero when no active debts")
    void shouldReturnZeroWhenNoActiveDebts() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveDebtRepository.sumPendingAmountByStateAndUser(StateDebt.ACTIVE, testUser))
                    .thenReturn(null);

            // When
            BigDecimal result = debtService.getTotalPendingAmount();

            // Then
            assertEquals(BigDecimal.ZERO, result);
        }
    }

    @Test
    @DisplayName("Should add debt successfully")
    void shouldAddDebtSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Debt newDebt = new Debt();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newDebtMapper.toEntity(newDebtDTO)).thenReturn(newDebt);

            // When
            debtService.addDebt(newDebtDTO);

            // Then
            verify(newDebtMapper).toEntity(newDebtDTO);
            verify(masterDebtRepository).save(argThat(debt -> debt.getUser().equals(testUser)));
        }
    }

    @Test
    @DisplayName("Should throw exception when expiration date before start date")
    void shouldThrowExceptionWhenExpirationDateBeforeStartDate() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        NewDebtDTO invalidDateDTO = new NewDebtDTO();
        invalidDateDTO.setName("Invalid Date Debt");
        invalidDateDTO.setTotalAmount(new BigDecimal("1000.00"));
        invalidDateDTO.setPendingAmount(new BigDecimal("1000.00"));
        invalidDateDTO.setStartDate(LocalDateTime.now());
        invalidDateDTO.setExpirationDate(LocalDateTime.now().minusDays(1)); // Before start date

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));

            // When & Then
            DebtException exception =
                    assertThrows(
                            DebtException.class,
                            () -> {
                                debtService.addDebt(invalidDateDTO);
                            });

            assertTrue(
                    exception
                            .getMessage()
                            .contains(
                                    "La fecha de vencimiento no puede ser anterior a la fecha de inicio"));
        }
    }

    @Test
    @DisplayName("Should throw exception when pending amount greater than total")
    void shouldThrowExceptionWhenPendingAmountGreaterThanTotal() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        NewDebtDTO invalidAmountDTO = new NewDebtDTO();
        invalidAmountDTO.setName("Invalid Amount Debt");
        invalidAmountDTO.setTotalAmount(new BigDecimal("1000.00"));
        invalidAmountDTO.setPendingAmount(new BigDecimal("1500.00")); // Greater than total
        invalidAmountDTO.setStartDate(LocalDateTime.now());
        invalidAmountDTO.setExpirationDate(LocalDateTime.now().plusDays(30));

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));

            // When & Then
            DebtException exception =
                    assertThrows(
                            DebtException.class,
                            () -> {
                                debtService.addDebt(invalidAmountDTO);
                            });

            assertTrue(
                    exception
                            .getMessage()
                            .contains("El monto pendiente no puede ser mayor al monto total"));
        }
    }

    @Test
    @DisplayName("Should make payment successfully with partial payment")
    void shouldMakePaymentSuccessfullyWithPartialPayment() {
        // Given
        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {

            when(slaveDebtRepository.findById(1)).thenReturn(Optional.of(testDebt));

            // When
            debtService.makePayment(debtPaymentDTO);

            // Then
            verify(masterDebtRepository)
                    .save(
                            argThat(
                                    debt ->
                                            debt.getPendingAmount()
                                                            .compareTo(new BigDecimal("2500.00"))
                                                    == 0 // 3000 - 500
                                    ));
        }
    }

    @Test
    @DisplayName("Should make payment successfully and mark as paid when fully paid")
    void shouldMakePaymentSuccessfullyAndMarkAsPaidWhenFullyPaid() {
        // Given
        DebtPaymentDTO fullPaymentDTO = new DebtPaymentDTO();
        fullPaymentDTO.setDebtId(1);
        fullPaymentDTO.setPaymentAmount(new BigDecimal("3000.00")); // Full pending amount

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {

            when(slaveDebtRepository.findById(1)).thenReturn(Optional.of(testDebt));

            // When
            debtService.makePayment(fullPaymentDTO);

            // Then
            verify(masterDebtRepository)
                    .save(
                            argThat(
                                    debt ->
                                            debt.getPendingAmount().compareTo(BigDecimal.ZERO) == 0
                                                    && debt.getState() == StateDebt.PAID));
        }
    }

    @Test
    @DisplayName("Should throw exception when trying to pay overpayment")
    void shouldThrowExceptionWhenTryingToPayOverpayment() {
        // Given
        DebtPaymentDTO overpaymentDTO = new DebtPaymentDTO();
        overpaymentDTO.setDebtId(1);
        overpaymentDTO.setPaymentAmount(new BigDecimal("5000.00")); // More than pending

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {

            when(slaveDebtRepository.findById(1)).thenReturn(Optional.of(testDebt));

            // When & Then
            DebtException exception =
                    assertThrows(
                            DebtException.class,
                            () -> {
                                debtService.makePayment(overpaymentDTO);
                            });

            assertTrue(
                    exception
                            .getMessage()
                            .contains("El monto del pago no puede ser mayor al monto pendiente"));
        }
    }

    @Test
    @DisplayName("Should throw exception when trying to pay inactive debt")
    void shouldThrowExceptionWhenTryingToPayInactiveDebt() {
        // Given
        testDebt.setState(StateDebt.PAID);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {

            when(slaveDebtRepository.findById(1)).thenReturn(Optional.of(testDebt));

            // When & Then
            DebtException exception =
                    assertThrows(
                            DebtException.class,
                            () -> {
                                debtService.makePayment(debtPaymentDTO);
                            });

            assertTrue(
                    exception
                            .getMessage()
                            .contains(
                                    "No se puede realizar un pago a una deuda que no está activa"));
        }
    }

    @Test
    @DisplayName("Should delete debt successfully")
    void shouldDeleteDebtSuccessfully() {
        // Given
        Integer debtId = 1;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveDebtRepository.existsById(debtId)).thenReturn(true);

            // When
            debtService.deleteDebt(debtId);

            // Then
            verify(masterDebtRepository).deleteById(debtId);
        }
    }

    @Test
    @DisplayName("Should throw exception when deleting non-existent debt")
    void shouldThrowExceptionWhenDeletingNonExistentDebt() {
        // Given
        Integer debtId = 999;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveDebtRepository.existsById(debtId)).thenReturn(false);

            // When & Then
            DebtException exception =
                    assertThrows(
                            DebtException.class,
                            () -> {
                                debtService.deleteDebt(debtId);
                            });

            assertTrue(exception.getMessage().contains("Deuda no encontrada con ID: 999"));
        }
    }

    @Test
    @DisplayName("Should update debt state successfully")
    void shouldUpdateDebtStateSuccessfully() {
        // Given
        Integer debtId = 1;
        StateDebt newState = StateDebt.PAID;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveDebtRepository.findById(debtId)).thenReturn(Optional.of(testDebt));

            // When
            debtService.updateDebtState(debtId, newState);

            // Then
            verify(masterDebtRepository).save(argThat(debt -> debt.getState() == newState));
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to access debt operations")
    void shouldThrowExceptionWhenProfileTriesToAccessDebtOperations() {
        // Given
        AuthCredentials profileCredentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(profileCredentials);

            // Test multiple operations
            assertThrows(DebtException.class, () -> debtService.getDebts());
            assertThrows(DebtException.class, () -> debtService.getDebtsByState(StateDebt.ACTIVE));
            assertThrows(DebtException.class, () -> debtService.getOverdueDebts());
            assertThrows(DebtException.class, () -> debtService.getDebtsExpiringInDays(7));
            assertThrows(DebtException.class, () -> debtService.getTotalPendingAmount());
            assertThrows(DebtException.class, () -> debtService.getDebtSummaryReport());
            assertThrows(DebtException.class, () -> debtService.addDebt(newDebtDTO));
            assertThrows(DebtException.class, () -> debtService.deleteDebt(1));
            assertThrows(DebtException.class, () -> debtService.updateDebtState(1, StateDebt.PAID));
        }
    }
}
