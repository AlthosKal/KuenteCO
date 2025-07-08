package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FeeDTO {
    @JsonProperty("fee_type")
    private String feeType;

    @JsonProperty("fee_amount")
    private BigDecimal feeAmount;

    @JsonProperty("fee_currency")
    private String feeCurrency;

    @JsonProperty("fee_description")
    private String feeDescription;
}
