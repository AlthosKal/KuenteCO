package org.kuenteco.backend.dto.subscription.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.PreapprovalStatus;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateSubscriptionResponseDTO {
    private Integer subscriptionId;
    private String preapprovalId;
    private String initPoint; // URL para completar el pago
    private String externalReference;
    private SubscriptionType subscriptionType;
    private BigDecimal monthlyAmount;
    private PreapprovalStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime nextPaymentDate;
}
