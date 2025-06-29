package org.kuenteco.backend.mapper.logic.category;

import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.mapper.logic.budget.UpdateBudgetMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(
        componentModel = "spring",
        uses = {UpdateBudgetMapper.class})
public interface UpdateCategoryMapper {
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "budget.id", source = "budgetId")
    Category toEntity(CategoryDTO dto);
}
