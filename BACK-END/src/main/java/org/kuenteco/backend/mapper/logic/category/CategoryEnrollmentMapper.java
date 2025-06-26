package org.kuenteco.backend.mapper.logic.category;

import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;
import org.kuenteco.backend.entity.CategoryEnrollment;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CategoryEnrollmentMapper {

    @Mapping(target = "userEmail", source = "user.email")
    @Mapping(target = "profileEmail", source = "profile.email")
    @Mapping(target = "categoryName", source = "category.description.name")
    CategoryEnrollmentDTO toDTO(CategoryEnrollment categoryEnrollment);

    List<CategoryEnrollmentDTO> toDTOList(List<CategoryEnrollment> categoryEnrollments);
}
