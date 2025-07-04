package org.kuenteco.backend.dto.subscription.wompi.response.api;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionPaymentResponseDTO {
    private Integer subscriptionId;
    private SubscriptionType subscriptionType;
    private BigDecimal amount;
    private String paymentStatus;
    private String transactionId;
    private LocalDateTime paymentDate;
    private String cardLastFour;
    private LocalDateTime expirationDate;
}
