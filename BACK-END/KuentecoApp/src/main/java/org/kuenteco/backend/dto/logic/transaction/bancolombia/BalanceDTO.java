package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

// DTO para balance
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BalanceDTO {
    @JsonProperty("available")
    private BigDecimal available;

    @JsonProperty("current")
    private BigDecimal current;

    @JsonProperty("credit_limit")
    private BigDecimal creditLimit;

    @JsonProperty("last_update")
    private LocalDateTime lastUpdate;
}
