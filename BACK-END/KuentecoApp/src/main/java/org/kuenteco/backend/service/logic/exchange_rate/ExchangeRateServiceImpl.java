package org.kuenteco.backend.service.logic.exchange_rate;

import java.math.BigDecimal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyRequestDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyResponseDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ExchangeRateDTO;
import org.kuenteco.backend.entity.extra.ExchangeRate;
import org.kuenteco.backend.exception.exceptions.ExchangeRateException;
import org.kuenteco.backend.mapper.logic.exchange_rate.ExchangeRateMapper;
import org.kuenteco.backend.repository.master.MasterExchangeRateRepository;
import org.kuenteco.backend.repository.slave.SlaveExchangeRateRepository;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class ExchangeRateServiceImpl implements ExchangeRateService {
    private final MasterExchangeRateRepository masterExchangeRateRepository;
    private final SlaveExchangeRateRepository slaveExchangeRateRepository;
    private final ExchangeRateMapper exchangeRateMapper;

    public List<ExchangeRateDTO> getAllRates() {
        List<ExchangeRate> rates = slaveExchangeRateRepository.findAll();

        if (rates.isEmpty()) {
            try {
                log.info("Actualizando tasas de cambio desde la API externa...");
                masterExchangeRateRepository.getExchangeRates();

                // Esperar un momento para que se complete la transacción
                Thread.sleep(2000);

                List<ExchangeRate> updated = masterExchangeRateRepository.findAll();
                if (updated.isEmpty()) {
                    log.warn("No se obtuvieron tasas de cambio después de la actualización");
                    throw new ExchangeRateException("No se pudieron obtener las tasas de cambio");
                }

                log.info("Tasas de cambio actualizadas exitosamente: {} registros", updated.size());
                return exchangeRateMapper.toDTOList(updated);

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                log.error("Proceso interrumpido durante la actualización de tasas", e);
                throw new ExchangeRateException("Error durante la actualización de tasas");
            } catch (Exception e) {
                log.error("Error actualizando tasas de cambio: ", e);
                throw new ExchangeRateException(
                        "No se pudieron actualizar las tasas de cambio: " + e.getMessage());
            }
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
