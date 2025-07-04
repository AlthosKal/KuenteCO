package org.kuenteco.backend.mapper.logic.budget;

import java.util.List;
import org.kuenteco.backend.dto.logic.budget.BudgetDTO;
import org.kuenteco.backend.entity.Budget;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface BudgetDetailMapper {
    BudgetDTO toDto(Budget budget);

    List<BudgetDTO> toDtoList(List<Budget> budgets);
}
