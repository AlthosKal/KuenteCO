package org.kuenteco.backend.dto.subscription.wompi.response.api;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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
