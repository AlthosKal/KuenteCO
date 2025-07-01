package org.kuenteco.backend.dto.logic.exchange_rate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ConvertCurrencyRequestDTO {
    private BigDecimal amount;
    private String baseCurrency;
    private String targetCurrency;
}
