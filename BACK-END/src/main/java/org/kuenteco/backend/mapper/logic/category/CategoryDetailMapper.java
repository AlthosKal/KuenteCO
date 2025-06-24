package org.kuenteco.backend.mapper.logic.category;

import java.util.List;
import org.kuenteco.backend.dto.logic.category.CategoryDetailDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.mapper.logic.budget.BudgetDetailMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(
        componentModel = "spring",
        uses = {BudgetDetailMapper.class})
public interface CategoryDetailMapper {
    @Mapping(target = "budget", source = "budget")
    CategoryDetailDTO toDto(Category category);

    List<CategoryDetailDTO> toDto(List<Category> categories);
}
