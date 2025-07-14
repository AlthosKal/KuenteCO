package org.kuenteco.backend.mapper.subscription;

import org.kuenteco.backend.dto.subscription.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.SubscriptionResponseDTO;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.kuenteco.backend.entity.Subscription;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface MercadoPagoPreapprovalMapper {

    @Mapping(source = "id", target = "subscriptionId")
    @Mapping(source = "preapprovalId", target = "preapprovalId")
    @Mapping(source = "initPoint", target = "initPoint")
    @Mapping(source = "externalReference", target = "externalReference")
    @Mapping(source = "autoRecurringTransactionAmount", target = "monthlyAmount")
    @Mapping(source = "status", target = "status")
    @Mapping(source = "dateCreated", target = "createdAt")
    @Mapping(source = "nextPaymentDate", target = "nextPaymentDate")
    @Mapping(source = "subscription.type", target = "subscriptionType")
    CreateSubscriptionResponseDTO toCreateSubscriptionResponse(MercadoPagoPreapproval preapproval);

    @Mapping(source = "subscription.id", target = "subscriptionId")
    @Mapping(source = "preapprovalId", target = "preapprovalId")
    @Mapping(source = "subscription.type", target = "subscriptionType")
    @Mapping(source = "autoRecurringTransactionAmount", target = "monthlyAmount")
    @Mapping(source = "subscription.state", target = "subscriptionState")
    @Mapping(source = "status", target = "preapprovalStatus")
    @Mapping(source = "subscription.startDate", target = "startDate")
    @Mapping(source = "subscription.expirationDate", target = "expirationDate")
    @Mapping(source = "nextPaymentDate", target = "nextPaymentDate")
    @Mapping(source = "subscription.isAutoRenewable", target = "isAutoRenewable")
    @Mapping(source = "paymentMethodId", target = "paymentMethodId")
    @Mapping(source = "cardLastFourDigits", target = "cardLastFourDigits")
    @Mapping(source = "cardBrand", target = "cardBrand")
    SubscriptionResponseDTO toSubscriptionResponse(MercadoPagoPreapproval preapproval);

    @Mapping(source = "subscription.id", target = "subscriptionId")
    @Mapping(source = "mercadoPagoPreapproval.preapprovalId", target = "preapprovalId")
    @Mapping(source = "subscription.type", target = "subscriptionType")
    @Mapping(
            source = "mercadoPagoPreapproval.autoRecurringTransactionAmount",
            target = "monthlyAmount")
    @Mapping(source = "subscription.state", target = "subscriptionState")
    @Mapping(source = "mercadoPagoPreapproval.status", target = "preapprovalStatus")
    @Mapping(source = "subscription.startDate", target = "startDate")
    @Mapping(source = "subscription.expirationDate", target = "expirationDate")
    @Mapping(source = "mercadoPagoPreapproval.nextPaymentDate", target = "nextPaymentDate")
    @Mapping(source = "subscription.isAutoRenewable", target = "isAutoRenewable")
    @Mapping(source = "mercadoPagoPreapproval.paymentMethodId", target = "paymentMethodId")
    @Mapping(source = "mercadoPagoPreapproval.cardLastFourDigits", target = "cardLastFourDigits")
    @Mapping(source = "mercadoPagoPreapproval.cardBrand", target = "cardBrand")
    SubscriptionResponseDTO toDTO(
            Subscription subscription, MercadoPagoPreapproval mercadoPagoPreapproval);
}
