package org.kuenteco.backend.entity.extra;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.PaymentMethod;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PayMethodInfo {
    @Enumerated(EnumType.STRING)
    private PaymentMethod method;

    private String cardLastFour;
    private String paymentEmail;
}
