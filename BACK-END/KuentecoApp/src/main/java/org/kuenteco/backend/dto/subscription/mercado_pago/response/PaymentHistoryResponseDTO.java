package org.kuenteco.backend.dto.subscription.mercado_pago.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.PaymentStatus;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentHistoryResponseDTO {
    private String paymentId;
    private BigDecimal amount;
    private String currencyId;
    private PaymentStatus status;
    private String statusDetail;
    private String paymentMethodId;
    private LocalDateTime dateCreated;
    private LocalDateTime dateApproved;
    private String description;
}
