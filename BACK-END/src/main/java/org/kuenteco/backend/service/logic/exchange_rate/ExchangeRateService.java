package org.kuenteco.backend.service.logic.exchange_rate;

import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyRequestDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyResponseDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ExchangeRateDTO;

import java.util.List;

public interface ExchangeRateService {
    List<ExchangeRateDTO> getAllRates();
    ConvertCurrencyResponseDTO convert(ConvertCurrencyRequestDTO dto);
}
