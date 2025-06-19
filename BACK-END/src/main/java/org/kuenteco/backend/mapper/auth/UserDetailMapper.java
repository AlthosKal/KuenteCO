package org.kuenteco.backend.mapper.auth;

import org.kuenteco.backend.dto.auth.UserDetailDTO;
import org.kuenteco.backend.entity.User;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserDetailMapper {

    UserDetailDTO toDto(User user);
}
