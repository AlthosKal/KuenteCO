package org.kuenteco.backend.mapper.profile;

import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.kuenteco.backend.entity.Profile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.Mappings;

@Mapper(componentModel = "spring")
public interface UpdateProfileMapper {
        @Mapping(target = "username", source = "username")
        @Mapping(target = "email", source = "email")
        @Mapping(
                target = "startDate",
                expression = "java(new java.sql.Timestamp(System.currentTimeMillis()))")
        @Mapping(target = "user", ignore = true)
        @Mapping(target = "role", ignore = true)
        @Mapping(target = "password", ignore = true)
        @Mapping(target = "image", ignore = true)
    void toEntity(UpdateProfileDTO dto, @MappingTarget Profile entity);
}
