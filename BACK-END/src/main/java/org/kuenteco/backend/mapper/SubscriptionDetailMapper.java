package org.kuenteco.backend.mapper;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.entity.PaySubscription;
import org.kuenteco.backend.entity.Subscription;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

@Mapper(componentModel = "spring")
public interface SubscriptionDetailMapper {

    @Mapping(target = "username", source = "subscription.user.username")
    @Mapping(target = "type", source = "subscription.type")
    @Mapping(
            target = "startDate",
            source = "subscription.startDate",
            qualifiedByName = "timestampToLocalDateTime")
    @Mapping(
            target = "expirationDate",
            source = "subscription.expirationDate",
            qualifiedByName = "timestampToLocalDateTime")
    @Mapping(target = "amount", source = "paySubscription.amount", qualifiedByName = "amountOrZero")
    SubscriptionDetailDTO toDto(Subscription subscription, PaySubscription paySubscription);

    @Named("timestampToLocalDateTime")
    default LocalDateTime timestampToLocalDateTime(java.sql.Timestamp timestamp) {
        if (timestamp == null) return null;
        return timestamp.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
    }

    @Named("amountOrZero")
    default BigDecimal amountOrZero(BigDecimal amount) {
        return amount != null ? amount : BigDecimal.ZERO;
    }
}
