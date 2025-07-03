package org.kuenteco.backend.mapper.subscription;

import java.math.BigDecimal;
import org.kuenteco.backend.dto.subscription.request.WompiTokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.request.WompiTransactionRequestDTO;
import org.kuenteco.backend.dto.subscription.request.api.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.request.api.TokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.request.extra.WompiCustomerDataDTO;
import org.kuenteco.backend.dto.subscription.request.extra.WompiPaymentMethodDTO;
import org.kuenteco.backend.dto.subscription.request.extra.WompiShippingAddressDTO;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.UserPaymentToken;
import org.kuenteco.backend.enums.CurrencyType;
import org.mapstruct.*;

/** Mapper para construcción de requests a la API de Wompi */
@Mapper(componentModel = "spring")
public interface WompiMapper {

    /** Convierte TokenizeCardRequestDTO a WompiTokenizeCardRequestDTO */
    @Mapping(source = "cardNumber", target = "number")
    @Mapping(source = "cvc", target = "cvc")
    @Mapping(source = "expiryMonth", target = "expMonth")
    @Mapping(source = "expiryYear", target = "expYear")
    @Mapping(source = "cardHolder", target = "cardHolder")
    WompiTokenizeCardRequestDTO toWompiTokenizeRequest(TokenizeCardRequestDTO request);

    /** Construye un WompiTransactionRequestDTO completo */
    @Mapping(target = "amountInCents", expression = "java(convertToAmountInCents(amount))")
    @Mapping(target = "currency", source = "currency")
    @Mapping(target = "signature", source = "signature")
    @Mapping(target = "customerEmail", source = "subscription.user.email")
    @Mapping(target = "reference", source = "reference")
    @Mapping(
            target = "paymentMethod",
            expression = "java(buildPaymentMethod(paymentToken, subscriptionRequest))")
    @Mapping(
            target = "shippingAddress",
            expression = "java(buildShippingAddress(subscriptionRequest))")
    @Mapping(target = "customerData", expression = "java(buildCustomerData(subscriptionRequest))")
    WompiTransactionRequestDTO toWompiTransactionRequest(
            Subscription subscription,
            UserPaymentToken paymentToken,
            BigDecimal amount,
            String reference,
            String signature,
            CurrencyType currency,
            CreateSubscriptionRequestDTO subscriptionRequest);

    /** Convierte BigDecimal a centavos (Long) */
    default Long convertToAmountInCents(BigDecimal amount) {
        return amount != null ? amount.multiply(BigDecimal.valueOf(100)).longValue() : null;
    }

    /** Construye el método de pago */
    default WompiPaymentMethodDTO buildPaymentMethod(
            UserPaymentToken paymentToken, CreateSubscriptionRequestDTO request) {
        if (paymentToken == null) return null;

        return WompiPaymentMethodDTO.builder()
                .type("CARD")
                .token(paymentToken.getWompiToken())
                .installments(request.getInstallments())
                .build();
    }

    /** Construye la dirección de envío por defecto */
    default WompiShippingAddressDTO buildShippingAddress(CreateSubscriptionRequestDTO request) {
        if (request == null || request.getShippingAddress() == null) return null;

        var shippingAddress = request.getShippingAddress();
        return WompiShippingAddressDTO.builder()
                .addressLine1(shippingAddress.getAddressLine1())
                .country(shippingAddress.getCountry())
                .region(shippingAddress.getRegion())
                .city(shippingAddress.getCity())
                .name(shippingAddress.getName())
                .phoneNumber(shippingAddress.getPhoneNumber())
                .build();
    }

    /** Construye los datos del cliente */
    default WompiCustomerDataDTO buildCustomerData(CreateSubscriptionRequestDTO request) {
        if (request == null || request.getCustomerData() == null) return null;

        var customerData = request.getCustomerData();
        return WompiCustomerDataDTO.builder()
                .phoneNumber(customerData.getPhoneNumber())
                .fullName(customerData.getFullName())
                .build();
    }
}
