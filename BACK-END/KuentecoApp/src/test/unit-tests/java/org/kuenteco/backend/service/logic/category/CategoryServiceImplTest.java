package org.kuenteco.backend.service.logic.category;

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
import org.kuenteco.backend.dto.logic.category.*;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.TransactionDetailDTO;
import org.kuenteco.backend.entity.Budget;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.TransactionType;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.category.CategoryDetailMapper;
import org.kuenteco.backend.mapper.logic.category.CategoryReportMapper;
import org.kuenteco.backend.mapper.logic.category.NewCategoryMapper;
import org.kuenteco.backend.mapper.logic.category.UpdateCategoryMapper;
import org.kuenteco.backend.mapper.logic.transaction.TransactionDetailMapper;
import org.kuenteco.backend.repository.master.MasterCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveTransactionRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
@DisplayName("CategoryServiceImpl Unit Tests")
class CategoryServiceImplTest {

    @InjectMocks private CategoryServiceImpl categoryService;

    @Mock private MasterCategoryRepository masterCategoryRepository;
    @Mock private SlaveCategoryRepository slaveCategoryRepository;
    @Mock private SlaveUserRepository slaveUserRepository;
    @Mock private CategoryDetailMapper categoryDetailMapper;
    @Mock private UpdateCategoryMapper updateCategoryMapper;
    @Mock private NewCategoryMapper newCategoryMapper;
    @Mock private SlaveBudgetRepository slaveBudgetRepository;
    @Mock private SlaveTransactionRepository slaveTransactionRepository;
    @Mock private CategoryReportMapper categoryReportMapper;
    @Mock private TransactionDetailMapper transactionDetailMapper;

    private User testUser;
    private Category testCategory;
    private NewCategoryDTO newCategoryDTO;
    private UpdateCategoryDTO updateCategoryDTO;
    private Budget testBudget;
    private DescriptionCategory testDescription;

    @BeforeEach
    void setUp() {
        // Setup test data
        testUser = new User();
        testUser.setId("test-user-id");
        testUser.setEmail("test@kuenteco.com");
        testUser.setUsername("testuser");

        testDescription = new DescriptionCategory();
        testDescription.setAssignedBudget(new BigDecimal("1000.00"));
        testDescription.setState(State.ACTIVE);

        testCategory = new Category();
        testCategory.setId(1);
        testCategory.setName("Test Category");
        testCategory.setDescription(testDescription);
        testCategory.setUser(testUser);
        testCategory.setRegisterDate(LocalDateTime.now());

        testBudget = new Budget();
        testBudget.setId(1);
        testBudget.setName("Test Budget");
        testBudget.setTotalBudget(new BigDecimal("5000.00"));

        newCategoryDTO = new NewCategoryDTO();
        newCategoryDTO.setBudgetId(1);
        newCategoryDTO.setName("New Category");
        newCategoryDTO.setDescription(testDescription);

        updateCategoryDTO = new UpdateCategoryDTO();
        updateCategoryDTO.setId(1);
        updateCategoryDTO.setBudgetId(1);
        updateCategoryDTO.setName("Updated Category");
        updateCategoryDTO.setDescription(testDescription);
    }

    @Test
    @DisplayName("Should get categories successfully for user")
    void shouldGetCategoriesSuccessfullyForUser() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<Category> categories = Arrays.asList(testCategory);
        List<CategoryDTO> categoryDTOs = Arrays.asList(new CategoryDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveCategoryRepository.findByUser(testUser)).thenReturn(categories);
            when(categoryDetailMapper.toDtoList(categories)).thenReturn(categoryDTOs);

            // When
            Object result = categoryService.getCategories();

            // Then
            assertNotNull(result);
            assertEquals(categoryDTOs, result);
            verify(slaveUserRepository).findByEmail("test@kuenteco.com");
            verify(slaveCategoryRepository).findByUser(testUser);
        }
    }

    @Test
    @DisplayName("Should return message when user has no categories")
    void shouldReturnMessageWhenUserHasNoCategories() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveCategoryRepository.findByUser(testUser)).thenReturn(Collections.emptyList());

            // When
            Object result = categoryService.getCategories();

            // Then
            assertEquals("No tienes rubros registrados", result);
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to get categories")
    void shouldThrowExceptionWhenProfileTriesToGetCategories() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            CategoryException exception =
                    assertThrows(
                            CategoryException.class,
                            () -> {
                                categoryService.getCategories();
                            });

            assertEquals("Endpoint solo disponible para usuarios", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should throw exception when user not found")
    void shouldThrowExceptionWhenUserNotFound() {
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
                                categoryService.getCategories();
                            });

            assertTrue(exception.getMessage().contains("Usuario no encontrado"));
        }
    }

    @Test
    @DisplayName("Should get category report successfully")
    void shouldGetCategoryReportSuccessfully() {
        // Given
        Integer categoryId = 1;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<Transaction> transactions = Arrays.asList(createMockTransaction());

        // Create a properly configured CategoryReportDTO
        CategoryDTO categoryDTO = new CategoryDTO();
        categoryDTO.setId(1);
        categoryDTO.setName("Test Category");
        categoryDTO.setDescription(testDescription);

        CategoryReportDTO reportDTO = new CategoryReportDTO();
        reportDTO.setCategory(categoryDTO);

        List<TransactionDetailDTO> transactionDTOs = Arrays.asList(new TransactionDetailDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveCategoryRepository.findByIdAndUser(categoryId, testUser))
                    .thenReturn(Optional.of(testCategory));
            when(slaveTransactionRepository.findByCategoryOrderByTransactionDateDesc(testCategory))
                    .thenReturn(transactions);
            when(categoryReportMapper.toDTO(testCategory)).thenReturn(reportDTO);
            when(transactionDetailMapper.toDtoList(transactions)).thenReturn(transactionDTOs);

            // When
            CategoryReportDTO result = categoryService.getCategoryReport(categoryId);

            // Then
            assertNotNull(result);
            assertEquals(reportDTO, result);
            verify(categoryReportMapper).toDTO(testCategory);
        }
    }

    @Test
    @DisplayName("Should throw exception when category not found for report")
    void shouldThrowExceptionWhenCategoryNotFoundForReport() {
        // Given
        Integer categoryId = 999;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(slaveCategoryRepository.findByIdAndUser(categoryId, testUser))
                    .thenReturn(Optional.empty());

            // When & Then
            CategoryException exception =
                    assertThrows(
                            CategoryException.class,
                            () -> {
                                categoryService.getCategoryReport(categoryId);
                            });

            assertTrue(
                    exception
                            .getMessage()
                            .contains("Categoría no encontrada con el Id: " + categoryId));
        }
    }

    @Test
    @DisplayName("Should add category successfully")
    void shouldAddCategorySuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Category newCategory = new Category();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newCategoryMapper.toEntity(newCategoryDTO)).thenReturn(newCategory);
            when(slaveBudgetRepository.findById(1)).thenReturn(Optional.of(testBudget));

            // When
            categoryService.addCategory(newCategoryDTO);

            // Then
            verify(newCategoryMapper).toEntity(newCategoryDTO);
            verify(masterCategoryRepository).save(any(Category.class));
        }
    }

    @Test
    @DisplayName("Should throw exception when profile tries to add category")
    void shouldThrowExceptionWhenProfileTriesToAddCategory() {
        // Given
        AuthCredentials credentials =
                new AuthCredentials("profile@kuenteco.com", RoleList.ROLE_PROFILE);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            CategoryException exception =
                    assertThrows(
                            CategoryException.class,
                            () -> {
                                categoryService.addCategory(newCategoryDTO);
                            });

            assertEquals("Endpoint solo disponible para usuarios", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should update category successfully")
    void shouldUpdateCategorySuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        Category updatedCategory = new Category();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(updateCategoryMapper.toEntity(updateCategoryDTO)).thenReturn(updatedCategory);
            when(slaveBudgetRepository.findById(1)).thenReturn(Optional.of(testBudget));

            // When
            categoryService.updateCategory(updateCategoryDTO);

            // Then
            verify(updateCategoryMapper).toEntity(updateCategoryDTO);
            verify(masterCategoryRepository).save(any(Category.class));
        }
    }

    @Test
    @DisplayName("Should delete category successfully")
    void shouldDeleteCategorySuccessfully() {
        // Given
        Integer categoryId = 1;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveCategoryRepository.existsById(categoryId)).thenReturn(true);

            // When
            categoryService.deleteCategory(categoryId);

            // Then
            verify(masterCategoryRepository).deleteById(categoryId);
        }
    }

    @Test
    @DisplayName("Should throw exception when deleting non-existent category")
    void shouldThrowExceptionWhenDeletingNonExistentCategory() {
        // Given
        Integer categoryId = 999;
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveCategoryRepository.existsById(categoryId)).thenReturn(false);

            // When & Then
            CategoryException exception =
                    assertThrows(
                            CategoryException.class,
                            () -> {
                                categoryService.deleteCategory(categoryId);
                            });

            assertTrue(
                    exception
                            .getMessage()
                            .contains("Rubro no encontrado con el ID: " + categoryId));
        }
    }

    @Test
    @DisplayName("Should throw exception when deleting category with null ID")
    void shouldThrowExceptionWhenDeletingCategoryWithNullId() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            // When & Then
            CategoryException exception =
                    assertThrows(
                            CategoryException.class,
                            () -> {
                                categoryService.deleteCategory(null);
                            });

            assertEquals("Id del rubro no puede ser nulo", exception.getMessage());
        }
    }

    @Test
    @DisplayName("Should get transactions by category successfully")
    void shouldGetTransactionsByCategorySuccessfully() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        List<TransactionsByCategoryDTO> transactionsDTOs =
                Arrays.asList(new TransactionsByCategoryDTO());

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveCategoryRepository.getTransactionsByCategoryAndUserEmail("test@kuenteco.com"))
                    .thenReturn(transactionsDTOs);

            // When
            Object result = categoryService.getTransactionsByCategory();

            // Then
            assertEquals(transactionsDTOs, result);
        }
    }

    @Test
    @DisplayName("Should return message when no categories with transactions found")
    void shouldReturnMessageWhenNoCategoriesWithTransactionsFound() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveCategoryRepository.getTransactionsByCategoryAndUserEmail("test@kuenteco.com"))
                    .thenReturn(Collections.emptyList());

            // When
            Object result = categoryService.getTransactionsByCategory();

            // Then
            assertEquals("No tienes categorías registradas", result);
        }
    }

    @Test
    @DisplayName("Should validate category description state transitions")
    void shouldValidateCategoryDescriptionStateTransitions() {
        // This test validates that the State enum in DescriptionCategory works correctly

        // Given
        DescriptionCategory description = new DescriptionCategory();

        // Test initial state
        description.setState(State.PENDING);
        assertEquals(State.PENDING, description.getState());

        // Test state transition
        description.setState(State.ACTIVE);
        assertEquals(State.ACTIVE, description.getState());

        // Test final state
        description.setState(State.CANCELLED);
        assertEquals(State.CANCELLED, description.getState());
    }

    @Test
    @DisplayName("Should handle budget assignment correctly")
    void shouldHandleBudgetAssignmentCorrectly() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        NewCategoryDTO dtoWithBudget = new NewCategoryDTO();
        dtoWithBudget.setBudgetId(1);
        dtoWithBudget.setName("Category with Budget");
        dtoWithBudget.setDescription(testDescription);

        Category categoryWithBudget = new Category();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(slaveUserRepository.findByEmail("test@kuenteco.com"))
                    .thenReturn(Optional.of(testUser));
            when(newCategoryMapper.toEntity(dtoWithBudget)).thenReturn(categoryWithBudget);
            when(slaveBudgetRepository.findById(1)).thenReturn(Optional.of(testBudget));

            // When
            categoryService.addCategory(dtoWithBudget);

            // Then
            verify(slaveBudgetRepository).findById(1);
            verify(masterCategoryRepository).save(any(Category.class));
        }
    }

    @Test
    @DisplayName("Should throw exception when budget not found")
    void shouldThrowExceptionWhenBudgetNotFound() {
        // Given
        AuthCredentials credentials = new AuthCredentials("test@kuenteco.com", RoleList.ROLE_USER);
        NewCategoryDTO dtoWithInvalidBudget = new NewCategoryDTO();
        dtoWithInvalidBudget.setBudgetId(999);
        dtoWithInvalidBudget.setName("Category with Invalid Budget");
        dtoWithInvalidBudget.setDescription(testDescription);

        Category category = new Category();

        try (MockedStatic<org.kuenteco.backend.service.auth.AuthServiceImpl> authService =
                mockStatic(org.kuenteco.backend.service.auth.AuthServiceImpl.class)) {
            authService
                    .when(() -> org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials())
                    .thenReturn(credentials);

            when(newCategoryMapper.toEntity(dtoWithInvalidBudget)).thenReturn(category);
            when(slaveBudgetRepository.findById(999)).thenReturn(Optional.empty());

            // When & Then
            CategoryException exception =
                    assertThrows(
                            CategoryException.class,
                            () -> {
                                categoryService.addCategory(dtoWithInvalidBudget);
                            });

            assertTrue(exception.getMessage().contains("Budget no encontrado por el Id: 999"));
        }
    }

    // Helper method to create mock transaction
    private Transaction createMockTransaction() {
        Transaction transaction = new Transaction();
        transaction.setId(1);
        transaction.setAmount(new BigDecimal("100.00"));
        transaction.setCategory(testCategory);

        // Add description to avoid NullPointerException
        DescriptionTransaction description = new DescriptionTransaction();
        description.setType(TransactionType.EXPENSE);
        transaction.setDescription(description);

        return transaction;
    }
}
