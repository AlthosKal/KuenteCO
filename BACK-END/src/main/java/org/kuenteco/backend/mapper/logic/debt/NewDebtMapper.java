package org.kuenteco.backend.mapper.logic.debt;

import org.kuenteco.backend.dto.logic.debt.NewDebtDTO;
import org.kuenteco.backend.entity.Debt;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NewDebtMapper {
    Debt toEntity(NewDebtDTO dto);
}
