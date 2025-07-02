package org.kuenteco.backend.entity.extra;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionPaymentHistory {
    private String typeSubscription;
    private String paymentMethod;
    private BigDecimal amount;
    private String date;
}
