package org.kuenteco.backend.mapper.logic.debt;

import org.kuenteco.backend.dto.logic.debt.NewDebtDTO;
import org.kuenteco.backend.entity.Debt;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface NewDebtMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "user", ignore = true)
    Debt toEntity(NewDebtDTO dto);
}
