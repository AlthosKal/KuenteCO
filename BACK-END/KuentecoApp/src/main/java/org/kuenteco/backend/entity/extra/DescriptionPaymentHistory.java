package org.kuenteco.backend.entity.extra;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.PaymentMethod;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionPaymentHistory {
    @Enumerated(EnumType.STRING)
    private SubscriptionType type;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    private BigDecimal amount;
    private LocalDateTime date;
}
