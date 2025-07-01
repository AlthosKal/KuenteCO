package org.kuenteco.backend.dto.logic.exchange_rate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExchangeRateDTO {
    private String baseCurrency;
    private String targetCurrency;
    private BigDecimal rate;
    private Timestamp lastUpdated;
}
