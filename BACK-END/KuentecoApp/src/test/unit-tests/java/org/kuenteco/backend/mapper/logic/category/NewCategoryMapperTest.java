package org.kuenteco.backend.mapper.logic.category;

import static org.junit.jupiter.api.Assertions.*;

import java.math.BigDecimal;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.enums.State;
import org.mapstruct.factory.Mappers;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
@DisplayName("NewCategoryMapper Unit Tests")
class NewCategoryMapperTest {

    private NewCategoryMapper mapper;
    private NewCategoryDTO sourceDTO;
    private DescriptionCategory testDescription;

    @BeforeEach
    void setUp() {
        // Initialize the mapper
        mapper = Mappers.getMapper(NewCategoryMapper.class);
        
        // Setup test data
        testDescription = new DescriptionCategory();
        testDescription.setAssignedBudget(new BigDecimal("1500.00"));
        testDescription.setState(State.ACTIVE);
        
        sourceDTO = new NewCategoryDTO();
        sourceDTO.setBudgetId(1);
        sourceDTO.setName("Test Category");
        sourceDTO.setDescription(testDescription);
    }

    @Test
    @DisplayName("Should map NewCategoryDTO to Category entity correctly")
    void shouldMapNewCategoryDTOToCategoryEntityCorrectly() {
        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result);
        assertEquals(sourceDTO.getName(), result.getName());
        assertEquals(sourceDTO.getDescription(), result.getDescription());
    }

    @Test
    @DisplayName("Should ignore ID field in mapping")
    void shouldIgnoreIdFieldInMapping() {
        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNull(result.getId()); // ID should be null as it's ignored in mapping
    }

    @Test
    @DisplayName("Should ignore user field in mapping")
    void shouldIgnoreUserFieldInMapping() {
        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNull(result.getUser()); // User should be null as it's ignored in mapping
    }

    @Test
    @DisplayName("Should ignore registerDate field in mapping")
    void shouldIgnoreRegisterDateFieldInMapping() {
        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNull(result.getRegisterDate()); // RegisterDate should be null as it's ignored in mapping
    }

    @Test
    @DisplayName("Should map budget ID correctly")
    void shouldMapBudgetIdCorrectly() {
        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result.getBudget());
        assertEquals(sourceDTO.getBudgetId(), result.getBudget().getId());
    }

    @Test
    @DisplayName("Should map category name correctly")
    void shouldMapCategoryNameCorrectly() {
        // Given
        String expectedName = "Financial Planning Category";
        sourceDTO.setName(expectedName);

        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertEquals(expectedName, result.getName());
    }

    @Test
    @DisplayName("Should map description correctly")
    void shouldMapDescriptionCorrectly() {
        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result.getDescription());
        assertEquals(testDescription.getAssignedBudget(), result.getDescription().getAssignedBudget());
        assertEquals(testDescription.getState(), result.getDescription().getState());
    }

    @Test
    @DisplayName("Should handle null DTO gracefully")
    void shouldHandleNullDTOGracefully() {
        // When
        Category result = mapper.toEntity(null);

        // Then
        assertNull(result);
    }

    @Test
    @DisplayName("Should handle DTO with null name")
    void shouldHandleDTOWithNullName() {
        // Given
        sourceDTO.setName(null);

        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result);
        assertNull(result.getName());
        assertEquals(sourceDTO.getDescription(), result.getDescription());
    }

    @Test
    @DisplayName("Should handle DTO with null budget ID")
    void shouldHandleDTOWithNullBudgetId() {
        // Given
        sourceDTO.setBudgetId(null);

        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result);
        // Budget might be null or have a null ID depending on MapStruct behavior
        if (result.getBudget() != null) {
            assertNull(result.getBudget().getId());
        }
    }

    @Test
    @DisplayName("Should handle DTO with null description")
    void shouldHandleDTOWithNullDescription() {
        // Given
        sourceDTO.setDescription(null);

        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result);
        assertNull(result.getDescription());
        assertEquals(sourceDTO.getName(), result.getName());
    }

    @Test
    @DisplayName("Should map description with different states correctly")
    void shouldMapDescriptionWithDifferentStatesCorrectly() {
        // Test with PENDING state
        testDescription.setState(State.PENDING);
        sourceDTO.setDescription(testDescription);
        
        Category result1 = mapper.toEntity(sourceDTO);
        assertEquals(State.PENDING, result1.getDescription().getState());
        
        // Test with INACTIVE state
        testDescription.setState(State.INACTIVE);
        sourceDTO.setDescription(testDescription);
        
        Category result2 = mapper.toEntity(sourceDTO);
        assertEquals(State.INACTIVE, result2.getDescription().getState());
        
        // Test with CANCELLED state
        testDescription.setState(State.CANCELLED);
        sourceDTO.setDescription(testDescription);
        
        Category result3 = mapper.toEntity(sourceDTO);
        assertEquals(State.CANCELLED, result3.getDescription().getState());
    }

    @Test
    @DisplayName("Should map description with different budget amounts correctly")
    void shouldMapDescriptionWithDifferentBudgetAmountsCorrectly() {
        // Test with zero budget
        testDescription.setAssignedBudget(BigDecimal.ZERO);
        sourceDTO.setDescription(testDescription);
        
        Category result1 = mapper.toEntity(sourceDTO);
        assertEquals(BigDecimal.ZERO, result1.getDescription().getAssignedBudget());
        
        // Test with large budget
        BigDecimal largeBudget = new BigDecimal("999999.99");
        testDescription.setAssignedBudget(largeBudget);
        sourceDTO.setDescription(testDescription);
        
        Category result2 = mapper.toEntity(sourceDTO);
        assertEquals(largeBudget, result2.getDescription().getAssignedBudget());
        
        // Test with null budget
        testDescription.setAssignedBudget(null);
        sourceDTO.setDescription(testDescription);
        
        Category result3 = mapper.toEntity(sourceDTO);
        assertNull(result3.getDescription().getAssignedBudget());
    }

    @Test
    @DisplayName("Should preserve description object integrity")
    void shouldPreserveDescriptionObjectIntegrity() {
        // Given - Create a complete description object
        DescriptionCategory complexDescription = new DescriptionCategory();
        complexDescription.setAssignedBudget(new BigDecimal("2500.50"));
        complexDescription.setState(State.SUSPENDED);
        
        sourceDTO.setDescription(complexDescription);

        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result.getDescription());
        assertEquals(complexDescription.getAssignedBudget(), result.getDescription().getAssignedBudget());
        assertEquals(complexDescription.getState(), result.getDescription().getState());
    }

    @Test
    @DisplayName("Should maintain field independence during mapping")
    void shouldMaintainFieldIndependenceDuringMapping() {
        // Given
        NewCategoryDTO dto1 = new NewCategoryDTO();
        dto1.setName("Category 1");
        dto1.setBudgetId(1);
        dto1.setDescription(testDescription);

        NewCategoryDTO dto2 = new NewCategoryDTO();
        dto2.setName("Category 2");
        dto2.setBudgetId(2);
        dto2.setDescription(testDescription);

        // When
        Category result1 = mapper.toEntity(dto1);
        Category result2 = mapper.toEntity(dto2);

        // Then
        assertNotEquals(result1.getName(), result2.getName());
        assertNotEquals(result1.getBudget().getId(), result2.getBudget().getId());
        assertEquals(result1.getDescription().getState(), result2.getDescription().getState());
        assertEquals(result1.getDescription().getAssignedBudget(), result2.getDescription().getAssignedBudget());
    }

    @Test
    @DisplayName("Should handle edge case with empty string name")
    void shouldHandleEdgeCaseWithEmptyStringName() {
        // Given
        sourceDTO.setName("");

        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result);
        assertEquals("", result.getName());
        assertNotNull(result.getDescription());
    }

    @Test
    @DisplayName("Should handle edge case with very long category name")
    void shouldHandleEdgeCaseWithVeryLongCategoryName() {
        // Given
        String longName = "A".repeat(1000); // Very long name
        sourceDTO.setName(longName);

        // When
        Category result = mapper.toEntity(sourceDTO);

        // Then
        assertNotNull(result);
        assertEquals(longName, result.getName());
        assertEquals(1000, result.getName().length());
    }
}
