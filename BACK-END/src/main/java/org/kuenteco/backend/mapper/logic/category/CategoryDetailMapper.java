package org.kuenteco.backend.mapper.logic.category;

import java.util.List;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CategoryDetailMapper {
    @Mapping(target = "budgetId", source = "budget.id")
    CategoryDTO toDto(Category category);

    List<CategoryDTO> toDtoList(List<Category> categories);
}
