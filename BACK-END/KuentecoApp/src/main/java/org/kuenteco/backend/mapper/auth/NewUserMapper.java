package org.kuenteco.backend.mapper.auth;

import org.kuenteco.backend.dto.auth.NewUserDTO;
import org.kuenteco.backend.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface NewUserMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "image", ignore = true)
    @Mapping(target = "role", ignore = true)
    @Mapping(target = "state", ignore = true)
    User toEntity(NewUserDTO newUserDTO);
}
