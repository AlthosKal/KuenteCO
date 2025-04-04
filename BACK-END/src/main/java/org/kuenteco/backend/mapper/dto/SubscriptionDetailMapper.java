package org.kuenteco.backend.mapper.dto;

import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.entity.slave.SlavePaySubscription;
import org.kuenteco.backend.entity.slave.SlaveSubscription;
import org.kuenteco.backend.enums.SubscriptionType;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.time.LocalDateTime;
import java.time.ZoneId;

@Mapper(componentModel = "spring")
public interface SubscriptionDetailMapper {

    @Mapping(target = "accountName", source = "slaveSubscription.slaveAccount.name")
    @Mapping(target = "type", source = "slaveSubscription.type", qualifiedByName = "mapSubscriptionType")
    @Mapping(target = "startDate", source = "slaveSubscription.startDate", qualifiedByName = "timestampToLocalDateTime")
    @Mapping(target = "expirationDate", source = "slaveSubscription.expirationDate", qualifiedByName = "timestampToLocalDateTime")
    @Mapping(target = "amount", source = "slavePaySubscription.amount", defaultValue = "0")
    SubscriptionDetailDTO toDto(SlaveSubscription slaveSubscription, SlavePaySubscription slavePaySubscription);

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