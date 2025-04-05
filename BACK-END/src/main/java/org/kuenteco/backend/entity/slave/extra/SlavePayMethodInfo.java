package org.kuenteco.backend.entity.slave.extra;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
public class SlavePayMethodInfo {
    @Column(name = "method")
    private String method;

    @Column(name = "card_last_four", length = 4)
    private String cardLastFour;

    @Column(name = "payment_email")
    private String paymentEmail;
}
