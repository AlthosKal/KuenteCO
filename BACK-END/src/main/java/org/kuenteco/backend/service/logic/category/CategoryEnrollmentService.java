package org.kuenteco.backend.service.logic.category;

import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;

import java.util.List;

public interface CategoryEnrollmentService {
    Object getAllCategoryEnrollments();
    CategoryEnrollmentDTO enrollProfileToCategory(Integer profileId, Integer categoryId);
    void removeCategoryEnrollment(Integer categoryEnrollmentId);
}
