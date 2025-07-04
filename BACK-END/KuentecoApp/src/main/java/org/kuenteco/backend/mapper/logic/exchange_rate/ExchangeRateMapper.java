package org.kuenteco.backend.mapper.logic.exchange_rate;

import java.util.List;
import org.kuenteco.backend.dto.logic.exchange_rate.ExchangeRateDTO;
import org.kuenteco.backend.entity.extra.ExchangeRate;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper(componentModel = "spring")
public interface ExchangeRateMapper {
    ExchangeRateMapper INSTANCE = Mappers.getMapper(ExchangeRateMapper.class);

    ExchangeRateDTO toDTO(ExchangeRate exchangeRate);

    List<ExchangeRateDTO> toDTOList(List<ExchangeRate> rates);
}
