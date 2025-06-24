package org.kuenteco.backend.mapper.profile;

import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.kuenteco.backend.entity.Profile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Mappings;

@Mapper(componentModel = "spring")
public interface UpdateProfileMapper {
    @Mappings({
        @Mapping(
                target = "startDate",
                expression = "java(new java.sql.Timestamp(System.currentTimeMillis()))"),
        @Mapping(target = "user", ignore = true),
        @Mapping(target = "image.id", ignore = true),
        @Mapping(target = "role", ignore = true)
    })
    Profile toEntity(UpdateProfileDTO dto);
}
