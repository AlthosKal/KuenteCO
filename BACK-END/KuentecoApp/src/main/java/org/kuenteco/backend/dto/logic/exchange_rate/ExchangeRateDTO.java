package org.kuenteco.backend.dto.logic.exchange_rate;

import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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
