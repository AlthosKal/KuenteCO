package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.entity.PaySubscription;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.enums.SubscriptionType;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.time.LocalDateTime;
import java.time.ZoneId;

@Mapper(componentModel = "spring")
public interface SubscriptionDetailMapper {

    @Mapping(target = "accountName", source = "subscription.account.name")
    @Mapping(target = "type", source = "subscription.type", qualifiedByName = "mapSubscriptionType")
    @Mapping(target = "startDate", source = "subscription.startDate", qualifiedByName = "timestampToLocalDateTime")
    @Mapping(target = "expirationDate", source = "subscription.expirationDate", qualifiedByName = "timestampToLocalDateTime")
    @Mapping(target = "amount", source = "paySubscription.amount", defaultValue = "0")
    SubscriptionDetailDTO toDto(Subscription subscription, PaySubscription paySubscription);

    @Named("timestampToLocalDateTime")
    default LocalDateTime timestampToLocalDateTime(java.sql.Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
    }

    @Named("mapSubscriptionType")
    default SubscriptionType mapSubscriptionType(String type) {
        if (type == null) {
            return null;
        }
        try {
            return SubscriptionType.valueOf(type.toUpperCase());
        } catch (IllegalArgumentException e) {
            return null; // o podrías lanzar una excepción específica
        }
    }
}