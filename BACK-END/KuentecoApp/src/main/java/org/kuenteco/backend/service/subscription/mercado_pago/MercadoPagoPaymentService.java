package org.kuenteco.backend.service.subscription.mercado_pago;

import java.util.List;
import org.kuenteco.backend.dto.subscription.mercado_pago.response.PaymentHistoryResponseDTO;

public interface MercadoPagoPaymentService {
    List<PaymentHistoryResponseDTO> getPaymentHistory(String preapprovalId, String userEmail);
}
