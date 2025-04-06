package org.kuenteco.backend.mapper.dto;

import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.master.extra.MasterImage;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ImageMapper {
    ImageDTO toDTO(MasterImage masterImage);
}
