package org.kuenteco.backend.mapper.logic.category;

import org.kuenteco.backend.dto.logic.category.CategoryReportDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.mapper.logic.budget.BudgetDetailMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(
        componentModel = "spring",
        uses = {CategoryDetailMapper.class, BudgetDetailMapper.class})
public interface CategoryReportMapper {
    @Mapping(source = "category", target = "category")
    @Mapping(source = "category.budget", target = "budget")
    @Mapping(target = "reportGeneratedAt", expression = "java(java.time.LocalDateTime.now())")
    @Mapping(target = "totalSpent", ignore = true)
    @Mapping(target = "totalIncome", ignore = true)
    @Mapping(target = "categoryRemainingBudget", ignore = true)
    @Mapping(target = "transactionCount", ignore = true)
    @Mapping(target = "transactions", ignore = true)
    CategoryReportDTO toDTO(Category category);
}
