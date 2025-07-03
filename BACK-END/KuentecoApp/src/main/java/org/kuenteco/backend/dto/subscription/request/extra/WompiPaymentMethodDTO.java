package org.kuenteco.backend.dto.subscription.request.extra;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WompiPaymentMethodDTO {
    private String type;
    private String token;
    private Integer installments;
}
