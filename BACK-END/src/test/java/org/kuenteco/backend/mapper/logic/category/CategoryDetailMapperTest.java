package org.kuenteco.backend.mapper.logic.category;

import static org.junit.jupiter.api.Assertions.*;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.entity.Budget;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@ExtendWith(MockitoExtension.class)
@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
class CategoryDetailMapperTest {

    @Autowired private CategoryDetailMapper categoryDetailMapper;

    private Category testCategory;
    private DescriptionCategory descriptionCategory;
    private Budget testBudget;

    @BeforeEach
    void setUp() {
        descriptionCategory = new DescriptionCategory();
        descriptionCategory.setName("Test Category");
        descriptionCategory.setDescription("Test Description");

        testBudget = Budget.builder().id(1).build();

        testCategory =
                Category.builder()
                        .id(1)
                        .budget(testBudget)
                        .description(descriptionCategory)
                        .startDate(Timestamp.valueOf(LocalDateTime.now()))
                        .finishDate(Timestamp.valueOf(LocalDateTime.now().plusMonths(1)))
                        .build();
    }

    @Test
    void testToDTO_Success() {
        // When
        CategoryDTO result = categoryDetailMapper.toDTO(testCategory);

        // Then
        assertNotNull(result);
        assertEquals(testCategory.getId(), result.getId());
        assertEquals(testCategory.getDescription(), result.getDescription());
        assertEquals(testCategory.getStartDate(), result.getStartDate());
        assertEquals(testCategory.getFinishDate(), result.getFinishDate());
        assertNotNull(result.getBudget());
    }

    @Test
    void testToDTO_NullInput() {
        // When
        CategoryDTO result = categoryDetailMapper.toDTO(null);

        // Then
        assertNull(result);
    }

    @Test
    void testToDTO_WithNullFields() {
        // Given
        Category categoryWithNulls =
                Category.builder().id(1).description(descriptionCategory).build();

        // When
        CategoryDTO result = categoryDetailMapper.toDTO(categoryWithNulls);

        // Then
        assertNotNull(result);
        assertEquals(categoryWithNulls.getId(), result.getId());
        assertEquals(categoryWithNulls.getDescription(), result.getDescription());
        assertNull(result.getStartDate());
        assertNull(result.getFinishDate());
    }
}
