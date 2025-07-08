package org.kuenteco.backend.service.subscription;

import java.util.List;
import org.kuenteco.backend.dto.subscription.response.PaymentHistoryResponseDTO;

public interface MercadoPagoPaymentService {
    List<PaymentHistoryResponseDTO> getPaymentHistory(String preapprovalId, String userEmail);
}
