package org.kuenteco.backend.mapper.logic.category;

import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.mapper.logic.budget.UpdateBudgetMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(
        componentModel = "spring",
        uses = {UpdateBudgetMapper.class})
public interface NewCategoryMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "budget.id", source = "budgetId")
    Category toEntity(NewCategoryDTO dto);
}
