package org.kuenteco.backend.mapper.logic.budget;

import java.util.List;
import org.kuenteco.backend.dto.logic.budget.BudgetDetailDTO;
import org.kuenteco.backend.entity.Budget;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface BudgetDetailMapper {
    BudgetDetailDTO toDto(Budget budget);

    List<BudgetDetailDTO> toDto(List<Budget> budgets);
}
