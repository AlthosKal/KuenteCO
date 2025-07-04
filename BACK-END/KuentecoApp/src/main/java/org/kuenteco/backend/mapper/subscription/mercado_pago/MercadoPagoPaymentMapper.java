package org.kuenteco.backend.mapper.subscription.mercado_pago;

import java.util.List;
import org.kuenteco.backend.dto.subscription.mercado_pago.response.PaymentHistoryResponseDTO;
import org.kuenteco.backend.entity.MercadoPagoPayment;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface MercadoPagoPaymentMapper {

    @Mapping(source = "paymentId", target = "paymentId")
    @Mapping(source = "transactionAmount", target = "amount")
    @Mapping(source = "currencyId", target = "currencyId")
    @Mapping(source = "status", target = "status")
    @Mapping(source = "statusDetail", target = "statusDetail")
    @Mapping(source = "paymentMethodId", target = "paymentMethodId")
    @Mapping(source = "dateCreated", target = "dateCreated")
    @Mapping(source = "dateApproved", target = "dateApproved")
    @Mapping(source = "description", target = "description")
    PaymentHistoryResponseDTO toPaymentHistoryResponse(MercadoPagoPayment payment);

    List<PaymentHistoryResponseDTO> toPaymentHistoryResponseList(List<MercadoPagoPayment> payments);
}
