package org.kuenteco.backend.mapper.subscription.wompi;

import org.kuenteco.backend.dto.subscription.wompi.response.api.SubscriptionPaymentResponseDTO;
import org.kuenteco.backend.entity.PaySubscription;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.UserPaymentToken;
import org.mapstruct.*;

/** Mapper para conversiones relacionadas con suscripciones */
@Mapper(componentModel = "spring")
public interface SubscriptionMapper {

    /** Mapea los datos de suscripción, pago y token a un DTO de respuesta */
    @Mapping(source = "subscription.id", target = "subscriptionId")
    @Mapping(source = "subscription.type", target = "subscriptionType")
    @Mapping(source = "paySubscription.amount", target = "amount")
    @Mapping(
            source = "paySubscription.status",
            target = "paymentStatus",
            qualifiedByName = "paymentStatusToString")
    @Mapping(source = "paySubscription.transactionId", target = "transactionId")
    @Mapping(source = "paySubscription.payDate", target = "paymentDate")
    @Mapping(source = "paymentToken.cardLastFour", target = "cardLastFour")
    @Mapping(source = "subscription.expirationDate", target = "expirationDate")
    SubscriptionPaymentResponseDTO toDTO(
            Subscription subscription,
            PaySubscription paySubscription,
            UserPaymentToken paymentToken);

    /** Mapea solo suscripción y pago (cuando no hay token disponible) */
    @Mapping(source = "subscription.id", target = "subscriptionId")
    @Mapping(source = "subscription.type", target = "subscriptionType")
    @Mapping(source = "paySubscription.amount", target = "amount")
    @Mapping(
            source = "paySubscription.status",
            target = "paymentStatus",
            qualifiedByName = "paymentStatusToString")
    @Mapping(source = "paySubscription.transactionId", target = "transactionId")
    @Mapping(source = "paySubscription.payDate", target = "paymentDate")
    @Mapping(source = "subscription.expirationDate", target = "expirationDate")
    @Mapping(target = "cardLastFour", ignore = true)
    SubscriptionPaymentResponseDTO toDTOWithToken(
            Subscription subscription, PaySubscription paySubscription);

    /** Convierte PaymentStatus enum a String */
    @Named("paymentStatusToString")
    default String paymentStatusToString(org.kuenteco.backend.enums.PaymentStatus status) {
        return status != null ? status.name() : null;
    }
}
