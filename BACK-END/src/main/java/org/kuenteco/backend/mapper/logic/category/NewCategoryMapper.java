package org.kuenteco.backend.mapper.logic.category;

import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NewCategoryMapper {

    Category toEntity(NewCategoryDTO dto);
}
