package org.kuenteco.backend.dto.logic.exchange_rate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConvertCurrencyResponseDTO {
    private BigDecimal convertedAmount;
    private String baseCurrency;
    private String targetCurrency;
    private BigDecimal rate;
}
