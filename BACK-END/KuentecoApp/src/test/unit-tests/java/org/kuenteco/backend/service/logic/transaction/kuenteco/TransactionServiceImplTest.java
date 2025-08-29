package org.kuenteco.backend.service.logic.transaction.kuenteco;

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
import org.kuenteco.backend.dto.logic.transaction.kuenteco.*;
import org.kuenteco.backend.entity.*;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.TransactionType;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.TransactionException;
import org.kuenteco.backend.mapper.logic.transaction.*;
import org.kuenteco.backend.repository.master.MasterTransactionRepository;
import org.kuenteco.backend.repository.slave.*;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
@DisplayName("TransactionServiceImpl Unit Tests")
class TransactionServiceImplTest {

    @InjectMocks private TransactionServiceImpl transactionService;

    @Mock private MasterTransactionRepository masterTransactionRepository;
    @Mock private SlaveTransactionRepository slaveTransactionRepository;
    @Mock private SlaveUserRepository slaveUserRepository;
    @Mock private SlaveProfileRepository slaveProfileRepository;
    @Mock private SlaveCategoryRepository slaveCategoryRepository;
    @Mock private SlaveBudgetRepository slaveBudgetRepository;
    @Mock private SlaveDebtRepository slaveDebtRepository;
    @Mock private TransactionDetailMapper transactionDetailMapper;
    @Mock private NewTransactionMapper newTransactionMapper;
    @Mock private UpdateTransactionMapper updateTransactionMapper;
    @Mock private ProfileWithTransactionsMapper profileWithTransactionsMapper;
    @Mock private TransactionSummaryMapper transactionSummaryMapper;

    private User testUser;
    private User businessUser;
    private Profile testProfile;
    private Transaction testTransaction;
    private Category testCategory;
    private Budget testBudget;
    private Debt testDebt;
    private NewTransactionDTO newTransactionDTO;
    private UpdateTransactionDTO updateTransactionDTO;

    @BeforeEach
    void setUp() {
        // Setup test users
        testUser = new User();
        testUser.setId("test-user-id");
        testUser.setEmail("test@kuenteco.com");
        testUser.setUsername("testuser");
        testUser.setType(UserType.PERSONAL);

        businessUser = new User();
        businessUser.setId("business-user-id");
        businessUser.setEmail("business@kuenteco.com");
        businessUser.setUsername("businessuser");
        businessUser.setType(UserType.BUSINESS);

        // Setup test profile
        testProfile = new Profile();
        testProfile.setId(1);
        testProfile.setEmail("profile@kuenteco.com");
        testProfile.setUser(businessUser);

        // Setup test category
        DescriptionCategory categoryDescription = new DescriptionCategory();
        categoryDescription.setAssignedBudget(new BigDecimal("1000.00"));
        categoryDescription.setState(State.ACTIVE);

        testCategory = new Category();
        testCategory.setId(1);
        testCategory.setName("Test Category");
        testCategory.setDescription(categoryDescription);
        testCategory.setUser(testUser);

        // Setup test budget
        testBudget = new Budget();
        testBudget.setId(1);
        testBudget.setName("Test Budget");
        testBudget.setTotalBudget(new BigDecimal("5000.00"));
        testBudget.setRemainingBudget(new BigDecimal("3000.00"));
        testBudget.setUser(testUser);

        // Setup test debt
        testDebt = new Debt();
        testDebt.setId(1);
        testDebt.setName("Test Debt");
        testDebt.setTotalAmount(new BigDecimal("2000.00"));
        testDebt.setPendingAmount(new BigDecimal("1500.00"));
        testDebt.setUser(testUser);

        // Setup test transaction
        DescriptionTransaction transactionDescription = new DescriptionTransaction();
        transactionDescription.setType(TransactionType.EXPENSE);
        transactionDescription.setDescription("Test transaction");

        testTransaction = new Transaction();
        testTransaction.setId(1);
        testTransaction.setName("Test Transaction");
        testTransaction.setAmount(new BigDecimal("100.00"));
        testTransaction.setDescription(transactionDescription);
        testTransaction.setUser(testUser);
        testTransaction.setCategory(testCategory);
        testTransaction.setTransactionDate(LocalDateTime.now());

        // Setup DTOs
        newTransactionDTO = new NewTransactionDTO();
        newTransactionDTO.setName("New Transaction");
        newTransactionDTO.setAmount(new BigDecimal("250.00"));
        newTransactionDTO.setCategoryId(1);
        newTransactionDTO.setBudgetId(1);
        newTransactionDTO.setDebtId(null);

        updateTransactionDTO = new UpdateTransactionDTO();
        updateTransactionDTO.setId(1);
        updateTransactionDTO.setName("Updated Transaction");
        updateTransactionDTO.setAmount(new BigDecimal("300.00"));
        updateTransactionDTO.setCategoryId(1);
    }

    @Test
    @DisplayName("Should get transactions for personal user successfully")
    void shouldGetTransactionsForPersonalUserSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<Transaction> transactions = Arrays.asList(testTransaction);
        List<TransactionDetailDTO> transactionDTOs = Arrays.asList(new TransactionDetailDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveTransactionRepository.findByUser(testUser)).thenReturn(transactions);
            when(transactionDetailMapper.toDtoList(transactions)).thenReturn(transactionDTOs);

            // When
            Object result = transactionService.getTransactions();

            // Then
            assertNotNull(result);
            assertEquals(transactionDTOs, result);
            verify(slaveTransactionRepository).findByUser(testUser);
            verify(transactionDetailMapper).toDtoList(transactions);
        }
    }

    @Test
    @DisplayName("Should get transactions for business user successfully")
    void shouldGetTransactionsForBusinessUserSuccessfully() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("business@kuenteco.com", RoleList.ROLE_USER);
        List<Profile> profiles = Arrays.asList(testProfile);
        List<Transaction> profileTransactions = Arrays.asList(testTransaction);

        ProfileWithTransactionsDTO profileWithTransactionsDTO = new ProfileWithTransactionsDTO();
        profileWithTransactionsDTO.setTransactionCount(1);

        UserProfilesWithTransactionsDTO expectedResult =
                UserProfilesWithTransactionsDTO.builder()
                        .username("businessuser")
                        .email("business@kuenteco.com")
                        .profiles(Arrays.asList(profileWithTransactionsDTO))
                        .totalProfiles(1)
                        .totalTransactions(1)
                        .build();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("business@kuenteco.com"))
                    .thenReturn(Optional.of(businessUser));
            when(slaveProfileRepository.findByUser(businessUser)).thenReturn(profiles);
            when(slaveTransactionRepository.findByProfile(testProfile))
                    .thenReturn(profileTransactions);
            when(profileWithTransactionsMapper.toDto(testProfile, profileTransactions))
                    .thenReturn(profileWithTransactionsDTO);

            // When
            Object result = transactionService.getTransactions();

            // Then
            assertNotNull(result);
            assertTrue(result instanceof UserProfilesWithTransactionsDTO);
            UserProfilesWithTransactionsDTO actualResult = (UserProfilesWithTransactionsDTO) result;
            assertEquals("businessuser", actualResult.getUsername());
            assertEquals("business@kuenteco.com", actualResult.getEmail());
            assertEquals(1, actualResult.getTotalProfiles());
            assertEquals(1, actualResult.getTotalTransactions());
        }
    }

    @Test
    @DisplayName("Should get transactions for profile successfully")
    void shouldGetTransactionsForProfileSuccessfully() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);
        List<Transaction> transactions = Arrays.asList(testTransaction);
        List<TransactionDetailDTO> transactionDTOs = Arrays.asList(new TransactionDetailDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveProfileRepository.findByEmail("profile@kuenteco.com"))
                    .thenReturn(Optional.of(testProfile));
            when(slaveTransactionRepository.findByProfile(testProfile)).thenReturn(transactions);
            when(transactionDetailMapper.toDtoList(transactions)).thenReturn(transactionDTOs);

            // When
            Object result = transactionService.getTransactions();

            // Then
            assertNotNull(result);
            assertEquals(transactionDTOs, result);
            verify(slaveTransactionRepository).findByProfile(testProfile);
        }
    }

    @Test
    @DisplayName("Should return message when user has no transactions")
    void shouldReturnMessageWhenUserHasNoTransactions() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveTransactionRepository.findByUser(testUser))
                    .thenReturn(Collections.emptyList());

            // When
            Object result = transactionService.getTransactions();

            // Then
            assertEquals("No tienes transacciones registradas", result);
        }
    }

    @Test
    @DisplayName("Should throw exception when user not found for transactions")
    void shouldThrowExceptionWhenUserNotFoundForTransactions() {
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
            TransactionException exception =
                    assertThrows(
                            TransactionException.class,
                            () -> {
                                transactionService.getTransactions();
                            });

            assertEquals("Usuario no encontrado", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should get transaction summary successfully")
    void shouldGetTransactionSummarySuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        // Mock raw data from database - this represents actual query results
        Object[] rawDataRow =
                new Object[] {
                    "user-123",
                    "PERSONAL",
                    null,
                    "Groceries",
                    "Food",
                    "Monthly Budget",
                    null,
                    5L,
                    3L,
                    2L,
                    new BigDecimal("1500.00"),
                    new BigDecimal("800.00"),
                    new BigDecimal("700.00"),
                    LocalDateTime.now().minusDays(30),
                    LocalDateTime.now()
                };
        List<Object[]> mockRawData = Collections.singletonList(rawDataRow);

        // Mock the expected result after mapping
        List<TransactionSummaryDTO> expectedSummary =
                Arrays.asList(
                        TransactionSummaryDTO.builder()
                                .ownerUserId("user-123")
                                .transactionOwnerType("PERSONAL")
                                .transactionName("Groceries")
                                .categoryName("Food")
                                .budgetName("Monthly Budget")
                                .transactionCount(5L)
                                .incomeCount(3L)
                                .expenseCount(2L)
                                .totalIncome(new BigDecimal("1500.00"))
                                .totalExpenses(new BigDecimal("800.00"))
                                .netAmount(new BigDecimal("700.00"))
                                .build());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // Mock repository call
            when(slaveTransactionRepository.findAllTransactionsSummariesRaw("test@kuenteco.com"))
                    .thenReturn(mockRawData);

            // Mock mapper conversion
            when(transactionSummaryMapper.fromObjectArrayList(mockRawData))
                    .thenReturn(expectedSummary);

            // When
            Object result = transactionService.getTransactionSummary();

            // Then
            assertNotNull(result);
            assertEquals(expectedSummary, result);
            assertTrue(result instanceof List);

            // Verify interactions
            verify(slaveTransactionRepository).findAllTransactionsSummariesRaw("test@kuenteco.com");
            verify(transactionSummaryMapper).fromObjectArrayList(mockRawData);
        }
    }

    @Test
    @DisplayName("Should return message when no transaction summary data found")
    void shouldReturnMessageWhenNoTransactionSummaryDataFound() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // Mock empty raw data from repository
            when(slaveTransactionRepository.findAllTransactionsSummariesRaw("test@kuenteco.com"))
                    .thenReturn(Collections.emptyList());

            // When
            Object result = transactionService.getTransactionSummary();

            // Then
            assertEquals("No tiene transacciones registradas", result);
            verify(slaveTransactionRepository).findAllTransactionsSummariesRaw("test@kuenteco.com");
            verifyNoInteractions(
                    transactionSummaryMapper); // Mapper should not be called when no data
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to get transaction summary")
    void shouldThrowExceptionWhenProfileTriesToGetTransactionSummary() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            TransactionException exception =
                    assertThrows(
                            TransactionException.class,
                            () -> {
                                transactionService.getTransactionSummary();
                            });

            assertEquals("Endpoint solo disponible para usuarios", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should add transaction for personal user successfully")
    void shouldAddTransactionForPersonalUserSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Transaction preparedTransaction = new Transaction();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newTransactionMapper.toEntity(newTransactionDTO)).thenReturn(preparedTransaction);
            when(slaveCategoryRepository.findById(1)).thenReturn(Optional.of(testCategory));
            when(slaveBudgetRepository.findById(1)).thenReturn(Optional.of(testBudget));

            // When
            transactionService.addTransaction(newTransactionDTO);

            // Then
            verify(newTransactionMapper).toEntity(newTransactionDTO);
            verify(slaveCategoryRepository).findById(1);
            verify(slaveBudgetRepository).findById(1);
            verify(masterTransactionRepository)
                    .save(
                            argThat(
                                    transaction ->
                                            transaction.getUser().equals(testUser)
                                                    && transaction
                                                            .getCategory()
                                                            .equals(testCategory)
                                                    && transaction.getBudget().equals(testBudget)));
        }
    }

    @Test
    @DisplayName("Should add transaction for profile successfully")
    void shouldAddTransactionForProfileSuccessfully() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);
        Transaction preparedTransaction = new Transaction();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveProfileRepository.findByEmail("profile@kuenteco.com"))
                    .thenReturn(Optional.of(testProfile));
            when(newTransactionMapper.toEntity(newTransactionDTO)).thenReturn(preparedTransaction);
            when(slaveCategoryRepository.findById(1)).thenReturn(Optional.of(testCategory));
            when(slaveBudgetRepository.findById(1)).thenReturn(Optional.of(testBudget));

            // When
            transactionService.addTransaction(newTransactionDTO);

            // Then
            verify(masterTransactionRepository)
                    .save(argThat(transaction -> transaction.getProfile().equals(testProfile)));
        }
    }

    @Test
    @DisplayName("Should throw exception when business user tries to add transaction directly")
    void shouldThrowExceptionWhenBusinessUserTriesToAddTransactionDirectly() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("business@kuenteco.com", RoleList.ROLE_USER);
        Transaction preparedTransaction = new Transaction();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("business@kuenteco.com"))
                    .thenReturn(Optional.of(businessUser));
            when(newTransactionMapper.toEntity(newTransactionDTO)).thenReturn(preparedTransaction);
            when(slaveCategoryRepository.findById(1)).thenReturn(Optional.of(testCategory));
            when(slaveBudgetRepository.findById(1)).thenReturn(Optional.of(testBudget));

            // When & Then
            TransactionException exception =
                    assertThrows(
                            TransactionException.class,
                            () -> {
                                transactionService.addTransaction(newTransactionDTO);
                            });

            assertEquals("Solo los perfiles pueden ingresar transacciones", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should throw exception when category not found for transaction")
    void shouldThrowExceptionWhenCategoryNotFoundForTransaction() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Transaction preparedTransaction = new Transaction();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(newTransactionMapper.toEntity(newTransactionDTO)).thenReturn(preparedTransaction);
            when(slaveCategoryRepository.findById(1)).thenReturn(Optional.empty());

            // When & Then
            TransactionException exception =
                    assertThrows(
                            TransactionException.class,
                            () -> {
                                transactionService.addTransaction(newTransactionDTO);
                            });

            assertTrue(exception.getMessage().contains("Categoría no encontrada con ID: 1"));
        }
    }

    @Test
    @DisplayName("Should update transaction successfully")
    void shouldUpdateTransactionSuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Transaction updatedTransaction = new Transaction();
        Transaction existingTransaction = new Transaction();
        existingTransaction.setId(1);

        updateTransactionDTO.setId(1); // importante!

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(org.kuenteco.backend.service.auth.AuthServiceImpl::getCredentials)
                    .thenReturn(credentials);

            when(slaveTransactionRepository.findById(1))
                    .thenReturn(Optional.of(existingTransaction)); // 👈 faltaba este mock
            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(updateTransactionMapper.toEntity(updateTransactionDTO))
                    .thenReturn(updatedTransaction);
            when(slaveCategoryRepository.findById(1)).thenReturn(Optional.of(testCategory));

            // When
            transactionService.updateTransaction(updateTransactionDTO);

            // Then
            verify(slaveTransactionRepository).findById(1);
            verify(updateTransactionMapper).toEntity(updateTransactionDTO);
            verify(masterTransactionRepository)
                    .save(argThat(transaction -> transaction.getUser().equals(testUser)));
        }
    }

    @Test
    @DisplayName("Should delete transaction successfully")
    void shouldDeleteTransactionSuccessfully() {
        // Given
        Integer transactionId = 1;
        when(masterTransactionRepository.existsById(transactionId)).thenReturn(true);

        // When
        transactionService.deleteTransaction(transactionId);

        // Then
        verify(masterTransactionRepository).deleteById(transactionId);
    }

    @Test
    @DisplayName("Should throw exception when deleting non-existent transaction")
    void shouldThrowExceptionWhenDeletingNonExistentTransaction() {
        // Given
        Integer transactionId = 999;
        when(masterTransactionRepository.existsById(transactionId)).thenReturn(false);

        // When & Then
        TransactionException exception =
                assertThrows(
                        TransactionException.class,
                        () -> {
                            transactionService.deleteTransaction(transactionId);
                        });

        assertTrue(exception.getMessage().contains("Transacción no encontrada con ID: 999"));
    }

    @Test
    @DisplayName("Should throw exception when deleting transaction with null ID")
    void shouldThrowExceptionWhenDeletingTransactionWithNullId() {
        // When & Then
        TransactionException exception =
                assertThrows(
                        TransactionException.class,
                        () -> {
                            transactionService.deleteTransaction(null);
                        });

        assertEquals("ID de transacción no puede ser nulo", exception.getMessage());
    }

    @Test
    @DisplayName("Should handle transaction with debt successfully")
    void shouldHandleTransactionWithDebtSuccessfully() {
        // Given
        newTransactionDTO.setDebtId(1);
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Transaction preparedTransaction = new Transaction();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newTransactionMapper.toEntity(newTransactionDTO)).thenReturn(preparedTransaction);
            when(slaveCategoryRepository.findById(1)).thenReturn(Optional.of(testCategory));
            when(slaveBudgetRepository.findById(1)).thenReturn(Optional.of(testBudget));
            when(slaveDebtRepository.findById(1)).thenReturn(Optional.of(testDebt));

            // When
            transactionService.addTransaction(newTransactionDTO);

            // Then
            verify(slaveDebtRepository).findById(1);
            verify(masterTransactionRepository)
                    .save(argThat(transaction -> transaction.getDebt().equals(testDebt)));
        }
    }

    @Test
    @DisplayName("Should handle transaction without optional fields successfully")
    void shouldHandleTransactionWithoutOptionalFieldsSuccessfully() {
        // Given
        newTransactionDTO.setBudgetId(null);
        newTransactionDTO.setDebtId(null);
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Transaction preparedTransaction = new Transaction();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newTransactionMapper.toEntity(newTransactionDTO)).thenReturn(preparedTransaction);
            when(slaveCategoryRepository.findById(1)).thenReturn(Optional.of(testCategory));

            // When
            transactionService.addTransaction(newTransactionDTO);

            // Then
            verify(masterTransactionRepository)
                    .save(
                            argThat(
                                    transaction ->
                                            transaction.getBudget() == null
                                                    && transaction.getDebt() == null));
        }
    }

    @Test
    @DisplayName("Should validate user type transition logic")
    void shouldValidateUserTypeTransitionLogic() {
        // This test validates that user type affects transaction handling

        // Given - Personal user should be able to create transactions directly
        AuthCredentials personalCredentials =
                new AuthCredentials("personal@kuenteco.com", RoleList.ROLE_USER);
        User personalUser = new User();
        personalUser.setType(UserType.PERSONAL);
        personalUser.setEmail("personal@kuenteco.com");

        Transaction preparedTransaction = new Transaction();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(personalCredentials);

            when(slaveUserRepository.findByEmail("personal@kuenteco.com"))
                    .thenReturn(Optional.of(personalUser));
            when(newTransactionMapper.toEntity(any())).thenReturn(preparedTransaction);
            when(slaveCategoryRepository.findById(any())).thenReturn(Optional.of(testCategory));
            when(slaveBudgetRepository.findById(1))
                    .thenReturn(Optional.of(testBudget)); // Add missing budget mock

            // When
            transactionService.addTransaction(newTransactionDTO);

            // Then
            verify(masterTransactionRepository)
                    .save(
                            argThat(
                                    transaction ->
                                            transaction.getUser().equals(personalUser)
                                                    && transaction.getProfile() == null));
        }
    }

    @Test
    @DisplayName("Should return empty profiles result for business user without profiles")
    void shouldReturnEmptyProfilesResultForBusinessUserWithoutProfiles() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("business@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("business@kuenteco.com"))
                    .thenReturn(Optional.of(businessUser));
            when(slaveProfileRepository.findByUser(businessUser))
                    .thenReturn(Collections.emptyList());

            // When
            Object result = transactionService.getTransactions();

            // Then
            assertTrue(result instanceof UserProfilesWithTransactionsDTO);
            UserProfilesWithTransactionsDTO dto = (UserProfilesWithTransactionsDTO) result;
            assertEquals(0, dto.getTotalProfiles());
            assertEquals(0, dto.getTotalTransactions());
            assertTrue(dto.getProfiles().isEmpty());
        }
    }
}
