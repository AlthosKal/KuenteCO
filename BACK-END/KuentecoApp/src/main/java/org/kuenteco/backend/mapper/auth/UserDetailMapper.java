package org.kuenteco.backend.mapper.auth;

import org.kuenteco.backend.dto.auth.UserDetailDTO;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.SubscriptionType;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserDetailMapper {


    @Mapping(target = "userType", source = "user.type")
    UserDetailDTO toDto(User user, SubscriptionType subscriptionType);
}
