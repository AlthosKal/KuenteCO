package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.extra.Image;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ImageMapper {
    ImageDTO toDTO(Image image);
}
