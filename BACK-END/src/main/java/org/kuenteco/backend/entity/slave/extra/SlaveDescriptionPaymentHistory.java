package org.kuenteco.backend.entity.slave.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SlaveDescriptionPaymentHistory implements Serializable {
    private String typeSubscription;
    private String paymentMethod;
    private BigDecimal amount;
    private String date;
}
