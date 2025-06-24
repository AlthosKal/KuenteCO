package org.kuenteco.backend.mapper.profile;

import java.util.List;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.entity.Profile;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ProfileDetailMapper {
    ProfileDetailDTO toDto(Profile profile);

    List<ProfileDetailDTO> toDtoList(List<Profile> profile);
}
