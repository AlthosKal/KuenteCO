package org.kuenteco.backend.mapper.subscription;

import org.kuenteco.backend.dto.subscription.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.SubscriptionResponseDTO;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.kuenteco.backend.entity.Subscription;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface MercadoPagoPreapprovalMapper {

    @Mapping(source = "preapproval.id", target = "subscriptionId")
    @Mapping(source = "preapproval.preapprovalId", target = "preapprovalId")
    @Mapping(source = "preapproval.initPoint", target = "initPoint")
    @Mapping(source = "preapproval.externalReference", target = "externalReference")
    @Mapping(source = "preapproval.autoRecurringTransactionAmount", target = "monthlyAmount")
    @Mapping(source = "preapproval.status", target = "status")
    @Mapping(source = "preapproval.dateCreated", target = "createdAt")
    @Mapping(source = "preapproval.nextPaymentDate", target = "nextPaymentDate")
    @Mapping(source = "subscription.type", target = "subscriptionType")
    CreateSubscriptionResponseDTO toCreateSubscriptionResponse(
            MercadoPagoPreapproval preapproval, Subscription subscription);

    @Mapping(source = "subscription.id", target = "subscriptionId")
    @Mapping(source = "preapproval.preapprovalId", target = "preapprovalId")
    @Mapping(source = "subscription.type", target = "subscriptionType")
    @Mapping(source = "preapproval.autoRecurringTransactionAmount", target = "monthlyAmount")
    @Mapping(source = "subscription.state", target = "subscriptionState")
    @Mapping(source = "preapproval.status", target = "preapprovalStatus")
    @Mapping(source = "subscription.startDate", target = "startDate")
    @Mapping(source = "subscription.expirationDate", target = "expirationDate")
    @Mapping(source = "preapproval.nextPaymentDate", target = "nextPaymentDate")
    @Mapping(source = "subscription.isAutoRenewable", target = "isAutoRenewable")
    @Mapping(source = "preapproval.paymentMethodId", target = "paymentMethodId")
    @Mapping(source = "preapproval.cardLastFourDigits", target = "cardLastFourDigits")
    @Mapping(source = "preapproval.cardBrand", target = "cardBrand")
    SubscriptionResponseDTO toSubscriptionResponse(
            MercadoPagoPreapproval preapproval, Subscription subscription);

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
