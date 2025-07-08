package org.kuenteco.backend.dto.subscription;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionPriceConfigDTO {
    private SubscriptionType type;
    private BigDecimal monthlyPrice;
    private String description;
    private String currencyId;
}
