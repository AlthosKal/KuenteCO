package org.kuenteco.backend.mapper.profile;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.entity.Profile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Mappings;
import org.mapstruct.Named;

@Mapper(componentModel = "spring")
public interface NewProfileMapper {


        @Mapping(target = "id", ignore = true)
        @Mapping(target = "user", ignore = true) // Se establecerá manualmente en el servicio
        @Mapping(target = "image", ignore = true)
        @Mapping(target = "role", ignore = true)
        @Mapping(target = "startDate", source = ".", qualifiedByName = "currentTimestamp")
    Profile toEntity(NewProfileDTO dto);

    @Named("currentTimestamp")
    default Timestamp mapCurrentTimestamp(NewProfileDTO source) {
        return Timestamp.valueOf(LocalDateTime.now());
    }
}
