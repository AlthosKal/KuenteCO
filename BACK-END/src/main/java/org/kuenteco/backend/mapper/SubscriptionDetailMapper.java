package org.kuenteco.backend.mapper;

import java.math.BigDecimal;
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
    @Mapping(target = "startDate", source = "subscription.startDate")
    @Mapping(target = "expirationDate", source = "subscription.expirationDate")
    @Mapping(target = "amount", source = "paySubscription.amount", qualifiedByName = "amountOrZero")
    SubscriptionDetailDTO toDto(Subscription subscription, PaySubscription paySubscription);

    @Named("amountOrZero")
    default BigDecimal amountOrZero(BigDecimal amount) {
        return amount != null ? amount : BigDecimal.ZERO;
    }
}
