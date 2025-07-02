package org.kuenteco.backend.dto.subscription.response.api;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentTokenResponseDTO {
    private Integer tokenId;
    private String cardLastFour;
    private String cardBrand;
    private String expiryMonth;
    private String expiryYear;
    private LocalDateTime createdAt;
    private Boolean isActive;
}
