package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO para información del comerciante
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MerchantInfoDTO {
    @JsonProperty("merchant_name")
    private String merchantName;

    @JsonProperty("merchant_id")
    private String merchantId;

    @JsonProperty("merchant_category")
    private String merchantCategory;

    @JsonProperty("location")
    private String location;
}
