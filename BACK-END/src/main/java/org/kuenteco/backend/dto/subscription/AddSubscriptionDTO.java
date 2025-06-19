package org.kuenteco.backend.dto.subscription;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionPaymentHistory;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AddSubscriptionDTO {
    private SubscriptionType type;
    private BigDecimal amount;
    private DescriptionPaymentHistory details;
}
