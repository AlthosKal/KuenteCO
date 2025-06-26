package org.kuenteco.backend.service.logic.category;

import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;

public interface CategoryEnrollmentService {
    Object getAllCategoryEnrollments();

    CategoryEnrollmentDTO enrollProfileToCategory(Integer profileId, Integer categoryId);

    void removeCategoryEnrollment(Integer id);
}
