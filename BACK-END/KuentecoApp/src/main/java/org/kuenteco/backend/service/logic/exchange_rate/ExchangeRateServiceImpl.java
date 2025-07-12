package org.kuenteco.backend.service.logic.exchange_rate;

import java.math.BigDecimal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyRequestDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyResponseDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ExchangeRateDTO;
import org.kuenteco.backend.entity.extra.ExchangeRate;
import org.kuenteco.backend.exception.exceptions.ExchangeRateException;
import org.kuenteco.backend.mapper.logic.exchange_rate.ExchangeRateMapper;
import org.kuenteco.backend.repository.master.MasterExchangeRateRepository;
import org.kuenteco.backend.repository.slave.SlaveExchangeRateRepository;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ExchangeRateServiceImpl implements ExchangeRateService {
    private final MasterExchangeRateRepository masterExchangeRateRepository;
    private final SlaveExchangeRateRepository slaveExchangeRateRepository;
    private final ExchangeRateMapper exchangeRateMapper;

    public List<ExchangeRateDTO> getAllRates() {
        List<ExchangeRate> rates = slaveExchangeRateRepository.findAll();

        if (rates.isEmpty()) {
            for (int i = 0; i < 4; i++) {
                masterExchangeRateRepository.getExchangeRates();
            }

            List<ExchangeRate> updated = masterExchangeRateRepository.findAll();
            return exchangeRateMapper.toDTOList(updated);
        }

        return exchangeRateMapper.toDTOList(rates);
    }



    public ConvertCurrencyResponseDTO convert(ConvertCurrencyRequestDTO dto) {
        ExchangeRate rate =
                slaveExchangeRateRepository
                        .findTopByBaseCurrencyAndTargetCurrencyOrderByLastUpdatedDesc(
                                dto.getBaseCurrency(), dto.getTargetCurrency())
                        .orElseThrow(() -> new ExchangeRateException("Tasa no encontrada"));

        BigDecimal result = dto.getAmount().multiply(rate.getRate());

        return ConvertCurrencyResponseDTO.builder()
                .convertedAmount(result)
                .baseCurrency(rate.getBaseCurrency())
                .targetCurrency(rate.getTargetCurrency())
                .rate(rate.getRate())
                .build();
    }
}
