package org.kuenteco.backend.dto.subscription.mercado_pago.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.PreapprovalStatus;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionResponseDTO {
    private Integer subscriptionId;
    private String preapprovalId;
    private SubscriptionType subscriptionType;
    private BigDecimal monthlyAmount;
    private State subscriptionState;
    private PreapprovalStatus preapprovalStatus;
    private LocalDateTime startDate;
    private LocalDateTime expirationDate;
    private LocalDateTime nextPaymentDate;
    private Boolean isAutoRenewable;
    private String paymentMethodId;
    private String cardLastFourDigits;
    private String cardBrand;
}
