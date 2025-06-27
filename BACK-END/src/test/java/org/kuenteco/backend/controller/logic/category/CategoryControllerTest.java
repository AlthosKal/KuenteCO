package org.kuenteco.backend.controller.logic.category;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.service.logic.category.CategoryEnrollmentService;
import org.kuenteco.backend.service.logic.category.CategoryService;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@ExtendWith(MockitoExtension.class)
@WebMvcTest(CategoryController.class)
class CategoryControllerTest {

    @Autowired private MockMvc mockMvc;

    @MockBean private CategoryService categoryService;

    @MockBean private CategoryEnrollmentService categoryEnrollmentService;

    @Autowired private ObjectMapper objectMapper;

    private NewCategoryDTO newCategoryDTO;
    private CategoryDTO categoryDTO;
    private CategoryEnrollmentDTO categoryEnrollmentDTO;
    private DescriptionCategory descriptionCategory;

    @BeforeEach
    void setUp() {
        descriptionCategory = new DescriptionCategory();
        descriptionCategory.setName("Test Category");
        descriptionCategory.setDescription("Test Description");

        newCategoryDTO = new NewCategoryDTO();
        newCategoryDTO.setBudgetId(1);
        newCategoryDTO.setDescription(descriptionCategory);
        newCategoryDTO.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        newCategoryDTO.setFinishDate(Timestamp.valueOf(LocalDateTime.now().plusMonths(1)));

        categoryDTO = new CategoryDTO();
        categoryDTO.setId(1);
        categoryDTO.setDescription(descriptionCategory);
        categoryDTO.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        categoryDTO.setFinishDate(Timestamp.valueOf(LocalDateTime.now().plusMonths(1)));

        categoryEnrollmentDTO = new CategoryEnrollmentDTO();
        categoryEnrollmentDTO.setId(1);
        categoryEnrollmentDTO.setProfileId(1);
        categoryEnrollmentDTO.setCategoryId(1);
    }

    @Test
    void testGetCategories_Success() throws Exception {
        // Given
        when(categoryService.getCategories()).thenReturn("categories data");

        // When & Then
        mockMvc.perform(get("/v1/category"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Categorías obtenidas correctamente"));

        verify(categoryService).getCategories();
    }

    @Test
    void testGetAllCategoryEnrollments_Success() throws Exception {
        // Given
        when(categoryEnrollmentService.getAllCategoryEnrollments()).thenReturn("enrollments data");

        // When & Then
        mockMvc.perform(get("/v1/category/enroll"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Categorías obtenidas correctamente"));

        verify(categoryEnrollmentService).getAllCategoryEnrollments();
    }

    @Test
    void testAddCategory_Success() throws Exception {
        // Given
        doNothing().when(categoryService).addCategory(any(NewCategoryDTO.class));

        // When & Then
        mockMvc.perform(
                        post("/v1/category/add")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(newCategoryDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Categoría creada correctamente"));

        verify(categoryService).addCategory(any(NewCategoryDTO.class));
    }

    @Test
    void testAddCategories_Success() throws Exception {
        // Given
        List<NewCategoryDTO> categories = Arrays.asList(newCategoryDTO);
        doNothing().when(categoryService).addCategory(any(NewCategoryDTO.class));

        // When & Then
        mockMvc.perform(
                        post("/v1/category/batch/add")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(categories)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Categoría creadas correctamente"));

        verify(categoryService, times(1)).addCategory(any(NewCategoryDTO.class));
    }

    @Test
    void testUpdateCategory_Success() throws Exception {
        // Given
        doNothing().when(categoryService).updateCategory(any(CategoryDTO.class));

        // When & Then
        mockMvc.perform(
                        patch("/v1/category/update")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(categoryDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Categoría actualizada correctamente"));

        verify(categoryService).updateCategory(any(CategoryDTO.class));
    }

    @Test
    void testUpdateCategories_Success() throws Exception {
        // Given
        List<CategoryDTO> categories = Arrays.asList(categoryDTO);
        doNothing().when(categoryService).updateCategory(any(CategoryDTO.class));

        // When & Then
        mockMvc.perform(
                        put("/v1/category/batch/update")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(categories)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Categoría actualizadas correctamente"));

        verify(categoryService, times(1)).updateCategory(any(CategoryDTO.class));
    }

    @Test
    void testEnrollProfileToCategory_Success() throws Exception {
        // Given
        when(categoryEnrollmentService.enrollProfileToCategory(anyInt(), anyInt()))
                .thenReturn(categoryEnrollmentDTO);

        // When & Then
        mockMvc.perform(
                        post("/v1/category/enroll/add")
                                .param("profileId", "1")
                                .param("categoryId", "1"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Categoría asignada correctamente"));

        verify(categoryEnrollmentService).enrollProfileToCategory(1, 1);
    }

    @Test
    void testDeleteCategory_Success() throws Exception {
        // Given
        doNothing().when(categoryService).deleteCategory(anyInt());

        // When & Then
        mockMvc.perform(delete("/v1/category/1"))
                .andExpect(status().isNoContent())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Categoría eliminada correctamente"));

        verify(categoryService).deleteCategory(1);
    }

    @Test
    void testDeleteCategories_Success() throws Exception {
        // Given
        doNothing().when(categoryService).deleteCategory(anyInt());

        // When & Then
        mockMvc.perform(delete("/v1/category/batch").param("id", "1", "2", "3"))
                .andExpect(status().isNoContent())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("3 Categorías eliminadas correctamente"));

        verify(categoryService, times(3)).deleteCategory(anyInt());
    }

    @Test
    void testRemoveCategoryEnrollment_Success() throws Exception {
        // Given
        doNothing().when(categoryEnrollmentService).removeCategoryEnrollment(anyInt());

        // When & Then
        mockMvc.perform(delete("/v1/category/enroll/1"))
                .andExpect(status().isNoContent())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Asignación eliminada correctamente"));

        verify(categoryEnrollmentService).removeCategoryEnrollment(1);
    }
}
