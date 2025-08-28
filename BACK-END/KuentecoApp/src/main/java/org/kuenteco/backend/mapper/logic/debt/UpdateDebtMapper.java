package org.kuenteco.backend.mapper.logic.debt;

import org.kuenteco.backend.dto.logic.debt.DebtDTO;
import org.kuenteco.backend.entity.Debt;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UpdateDebtMapper {
    @Mapping(target = "user", ignore = true)
    Debt toEntity(DebtDTO dto);
}
