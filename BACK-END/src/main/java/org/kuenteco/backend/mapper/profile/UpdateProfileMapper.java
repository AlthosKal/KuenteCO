package org.kuenteco.backend.mapper.profile;

import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.kuenteco.backend.entity.Profile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UpdateProfileMapper {
    @Mapping(
            target = "startDate",
            expression = "java(new java.sql.Timestamp(System.currentTimeMillis()))")
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "image.id", ignore = true)
    Profile toEntity(UpdateProfileDTO dto);
}
