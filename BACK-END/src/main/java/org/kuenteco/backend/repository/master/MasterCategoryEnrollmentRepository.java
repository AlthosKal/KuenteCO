package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;
import org.kuenteco.backend.entity.CategoryEnrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MasterCategoryEnrollmentRepository extends JpaRepository<CategoryEnrollment, Integer> {
}
