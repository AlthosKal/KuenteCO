package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.CategoryEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SlaveCategoryEnrollmentRepository extends JpaRepository<CategoryEnrollment, Integer> {
    List<CategoryEnrollment> findByProfile(Profile profile);
}
