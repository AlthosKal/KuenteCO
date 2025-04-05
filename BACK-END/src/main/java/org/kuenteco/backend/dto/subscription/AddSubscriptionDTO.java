package org.kuenteco.backend.dto.subscription;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.master.extra.MasterDescriptionPaymentHistory;
import org.kuenteco.backend.enums.SubscriptionType;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AddSubscriptionDTO {
    private SubscriptionType type;
    private BigDecimal amount;
    private MasterDescriptionPaymentHistory details;

}
