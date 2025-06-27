package org.kuenteco.backend.service.logic.category;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.category.CategoryDetailMapper;
import org.kuenteco.backend.mapper.logic.category.NewCategoryMapper;
import org.kuenteco.backend.mapper.logic.category.UpdateCategoryMapper;
import org.kuenteco.backend.repository.master.MasterCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.service.logic.budget.BudgetService;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CategoryServiceTest {

    @Mock private MasterCategoryRepository masterCategoryRepository;

    @Mock private SlaveCategoryRepository slaveCategoryRepository;

    @Mock private BudgetService budgetService;

    @Mock private NewCategoryMapper newCategoryMapper;

    @Mock private CategoryDetailMapper categoryDetailMapper;

    @Mock private UpdateCategoryMapper updateCategoryMapper;

    @InjectMocks private CategoryServiceImpl categoryService;

    private Category testCategory;
    private NewCategoryDTO newCategoryDTO;
    private CategoryDTO categoryDTO;
    private DescriptionCategory descriptionCategory;

    @BeforeEach
    void setUp() {
        descriptionCategory = new DescriptionCategory();
        descriptionCategory.setName("Test Category");
        descriptionCategory.setDescription("Test Description");

        testCategory =
                Category.builder()
                        .id(1)
                        .description(descriptionCategory)
                        .startDate(Timestamp.valueOf(LocalDateTime.now()))
                        .finishDate(Timestamp.valueOf(LocalDateTime.now().plusMonths(1)))
                        .build();

        newCategoryDTO = new NewCategoryDTO();
        newCategoryDTO.setBudgetId(1);
        newCategoryDTO.setDescription(descriptionCategory);

        categoryDTO = new CategoryDTO();
        categoryDTO.setId(1);
        categoryDTO.setDescription(descriptionCategory);
    }

    @Test
    void testGetCategories_Success() {
        // Given
        List<Category> categories = Arrays.asList(testCategory);
        when(slaveCategoryRepository.findAll()).thenReturn(categories);

        // When
        Object result = categoryService.getCategories();

        // Then
        assertNotNull(result);
        verify(slaveCategoryRepository).findAll();
    }

    @Test
    void testAddCategory_Success() {
        // Given
        when(newCategoryMapper.toEntity(any())).thenReturn(testCategory);
        when(masterCategoryRepository.save(any())).thenReturn(testCategory);

        // When
        assertDoesNotThrow(() -> categoryService.addCategory(newCategoryDTO));

        // Then
        verify(newCategoryMapper).toEntity(newCategoryDTO);
        verify(masterCategoryRepository).save(any(Category.class));
    }

    @Test
    void testAddCategory_ThrowsException() {
        // Given
        when(newCategoryMapper.toEntity(any())).thenReturn(testCategory);
        when(masterCategoryRepository.save(any()))
                .thenThrow(new RuntimeException("Database error"));

        // When & Then
        assertThrows(CategoryException.class, () -> categoryService.addCategory(newCategoryDTO));
    }

    @Test
    void testUpdateCategory_Success() {
        // Given
        when(slaveCategoryRepository.findById(anyInt())).thenReturn(Optional.of(testCategory));
        when(updateCategoryMapper.toEntity(any())).thenReturn(testCategory);
        when(masterCategoryRepository.save(any())).thenReturn(testCategory);

        // When
        assertDoesNotThrow(() -> categoryService.updateCategory(categoryDTO));

        // Then
        verify(slaveCategoryRepository).findById(categoryDTO.getId());
        verify(updateCategoryMapper).toEntity(categoryDTO);
        verify(masterCategoryRepository).save(any(Category.class));
    }

    @Test
    void testUpdateCategory_CategoryNotFound() {
        // Given
        when(slaveCategoryRepository.findById(anyInt())).thenReturn(Optional.empty());

        // When & Then
        assertThrows(CategoryException.class, () -> categoryService.updateCategory(categoryDTO));
    }

    @Test
    void testDeleteCategory_Success() {
        // Given
        when(slaveCategoryRepository.findById(anyInt())).thenReturn(Optional.of(testCategory));

        // When
        assertDoesNotThrow(() -> categoryService.deleteCategory(1));

        // Then
        verify(slaveCategoryRepository).findById(1);
        verify(masterCategoryRepository).delete(testCategory);
    }

    @Test
    void testDeleteCategory_CategoryNotFound() {
        // Given
        when(slaveCategoryRepository.findById(anyInt())).thenReturn(Optional.empty());

        // When & Then
        assertThrows(CategoryException.class, () -> categoryService.deleteCategory(1));
    }
}
