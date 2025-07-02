package org.kuenteco.backend.service.logic.exchange_rate;

import java.util.List;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyRequestDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyResponseDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ExchangeRateDTO;

public interface ExchangeRateService {
    List<ExchangeRateDTO> getAllRates();

    ConvertCurrencyResponseDTO convert(ConvertCurrencyRequestDTO dto);
}
