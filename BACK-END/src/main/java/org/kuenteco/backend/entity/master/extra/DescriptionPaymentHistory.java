package org.kuenteco.backend.entity.master.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionPaymentHistory implements Serializable {
    private String typeSubscription;
    private String paymentMethod;
    private double amount;
    private String date;
}
