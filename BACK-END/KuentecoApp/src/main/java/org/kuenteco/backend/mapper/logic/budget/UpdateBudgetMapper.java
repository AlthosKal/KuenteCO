package org.kuenteco.backend.mapper.logic.budget;

import org.kuenteco.backend.dto.logic.budget.BudgetDTO;
import org.kuenteco.backend.entity.Budget;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UpdateBudgetMapper {
    @Mapping(target = "user", ignore = true)
    Budget toEntity(BudgetDTO dto);
}
