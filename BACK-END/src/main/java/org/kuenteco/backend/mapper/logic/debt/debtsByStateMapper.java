package org.kuenteco.backend.mapper.logic.debt;

import java.util.List;
import org.kuenteco.backend.dto.logic.debt.DebtDTO;
import org.kuenteco.backend.enums.StateDebt;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface debtsByStateMapper {
    List<DebtDTO> toDtoList(StateDebt state);
}
