package org.kuenteco.backend.mapper.logic.debt;

import java.util.List;
import org.kuenteco.backend.dto.logic.debt.DebtDTO;
import org.kuenteco.backend.entity.Debt;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface DebtDetailMapper {
    List<DebtDTO> toDtoList(List<Debt> debts);
}
