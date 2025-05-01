package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.auth.RoleDetailDTO;
import org.kuenteco.backend.entity.Role;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface RoleDetailMapper {
    RoleDetailDTO toDto(Role role);
}
