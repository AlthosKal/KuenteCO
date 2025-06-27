package org.kuenteco.backend.service.logic.category;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.CategoryEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.category.CategoryEnrollmentMapper;
import org.kuenteco.backend.repository.master.MasterCategoryEnrollmentRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryEnrollmentRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CategoryEnrollmentServiceTest {

    @Mock private MasterCategoryEnrollmentRepository masterCategoryEnrollmentRepository;

    @Mock private SlaveCategoryEnrollmentRepository slaveCategoryEnrollmentRepository;

    @Mock private SlaveCategoryRepository slaveCategoryRepository;

    @Mock private SlaveProfileRepository slaveProfileRepository;

    @Mock private CategoryEnrollmentMapper categoryEnrollmentMapper;

    @InjectMocks private CategoryEnrollmentServiceImpl categoryEnrollmentService;

    private CategoryEnrollment testCategoryEnrollment;
    private CategoryEnrollmentDTO categoryEnrollmentDTO;
    private Category testCategory;
    private Profile testProfile;

    @BeforeEach
    void setUp() {
        testCategory = Category.builder().id(1).build();

        testProfile = Profile.builder().id(1).build();

        testCategoryEnrollment =
                CategoryEnrollment.builder()
                        .id(1)
                        .category(testCategory)
                        .profile(testProfile)
                        .build();

        categoryEnrollmentDTO = new CategoryEnrollmentDTO();
        categoryEnrollmentDTO.setId(1);
        categoryEnrollmentDTO.setCategoryId(1);
        categoryEnrollmentDTO.setProfileId(1);
    }

    @Test
    void testGetAllCategoryEnrollments_Success() {
        // Given
        List<CategoryEnrollment> enrollments = Arrays.asList(testCategoryEnrollment);
        when(slaveCategoryEnrollmentRepository.findAll()).thenReturn(enrollments);

        // When
        Object result = categoryEnrollmentService.getAllCategoryEnrollments();

        // Then
        assertNotNull(result);
        verify(slaveCategoryEnrollmentRepository).findAll();
    }

    @Test
    void testEnrollProfileToCategory_Success() {
        // Given
        when(slaveProfileRepository.findById(anyInt())).thenReturn(Optional.of(testProfile));
        when(slaveCategoryRepository.findById(anyInt())).thenReturn(Optional.of(testCategory));
        when(masterCategoryEnrollmentRepository.save(any())).thenReturn(testCategoryEnrollment);
        when(categoryEnrollmentMapper.toDTO(any())).thenReturn(categoryEnrollmentDTO);

        // When
        CategoryEnrollmentDTO result = categoryEnrollmentService.enrollProfileToCategory(1, 1);

        // Then
        assertNotNull(result);
        assertEquals(1, result.getId());
        verify(slaveProfileRepository).findById(1);
        verify(slaveCategoryRepository).findById(1);
        verify(masterCategoryEnrollmentRepository).save(any(CategoryEnrollment.class));
        verify(categoryEnrollmentMapper).toDTO(testCategoryEnrollment);
    }

    @Test
    void testEnrollProfileToCategory_ProfileNotFound() {
        // Given
        when(slaveProfileRepository.findById(anyInt())).thenReturn(Optional.empty());

        // When & Then
        assertThrows(
                CategoryException.class,
                () -> categoryEnrollmentService.enrollProfileToCategory(1, 1));
    }

    @Test
    void testEnrollProfileToCategory_CategoryNotFound() {
        // Given
        when(slaveProfileRepository.findById(anyInt())).thenReturn(Optional.of(testProfile));
        when(slaveCategoryRepository.findById(anyInt())).thenReturn(Optional.empty());

        // When & Then
        assertThrows(
                CategoryException.class,
                () -> categoryEnrollmentService.enrollProfileToCategory(1, 1));
    }

    @Test
    void testRemoveCategoryEnrollment_Success() {
        // Given
        when(slaveCategoryEnrollmentRepository.findById(anyInt()))
                .thenReturn(Optional.of(testCategoryEnrollment));

        // When
        assertDoesNotThrow(() -> categoryEnrollmentService.removeCategoryEnrollment(1));

        // Then
        verify(slaveCategoryEnrollmentRepository).findById(1);
        verify(masterCategoryEnrollmentRepository).delete(testCategoryEnrollment);
    }

    @Test
    void testRemoveCategoryEnrollment_EnrollmentNotFound() {
        // Given
        when(slaveCategoryEnrollmentRepository.findById(anyInt())).thenReturn(Optional.empty());

        // When & Then
        assertThrows(
                CategoryException.class,
                () -> categoryEnrollmentService.removeCategoryEnrollment(1));
    }

    @Test
    void testEnrollProfileToCategory_DatabaseError() {
        // Given
        when(slaveProfileRepository.findById(anyInt())).thenReturn(Optional.of(testProfile));
        when(slaveCategoryRepository.findById(anyInt())).thenReturn(Optional.of(testCategory));
        when(masterCategoryEnrollmentRepository.save(any()))
                .thenThrow(new RuntimeException("Database error"));

        // When & Then
        assertThrows(
                CategoryException.class,
                () -> categoryEnrollmentService.enrollProfileToCategory(1, 1));
    }
}
