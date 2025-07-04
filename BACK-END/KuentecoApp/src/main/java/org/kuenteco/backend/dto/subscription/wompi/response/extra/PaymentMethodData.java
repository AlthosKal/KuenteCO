package org.kuenteco.backend.dto.subscription.wompi.response.extra;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentMethodData {
    private String type;
    private String extra;
    private Integer installments;

    @JsonProperty("payment_description")
    private String paymentDescription;
}
