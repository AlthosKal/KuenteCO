package org.kuenteco.backend.mapper.logic.category;

import java.util.List;

import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.mapper.logic.budget.BudgetDetailMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(
        componentModel = "spring",
        uses = {BudgetDetailMapper.class})
public interface CategoryMapper {
    @Mapping(target = "budget", source = "budget")
    CategoryDTO toDto(Category category);

    List<CategoryDTO> toDtoList(List<Category> categories);

    Category toEntity(CategoryDTO dto);
}
