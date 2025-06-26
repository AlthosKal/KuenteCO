package org.kuenteco.backend.mapper.logic.budget;

import org.kuenteco.backend.dto.logic.budget.NewBudgetDTO;
import org.kuenteco.backend.entity.Budget;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface NewBudgetMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "user", ignore = true)
    Budget toEntity(NewBudgetDTO dto);
}
