package org.kuenteco.backend.repository.slave;

import java.util.List;

import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentSummaryDTO;
import org.kuenteco.backend.entity.CategoryEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveCategoryEnrollmentRepository
        extends JpaRepository<CategoryEnrollment, Integer> {
    List<CategoryEnrollment> findByProfile(Profile profile);

    boolean existsByCategoryIdAndProfile_Id(Integer categoryId, Integer profileId);

    @Query(value = """
        SELECT v.* FROM vw_category_enrollments v
        WHERE v.owner_user_id = (SELECT id FROM kuentecouser WHERE email = :email)
        """, nativeQuery = true)
    List<CategoryEnrollmentSummaryDTO> findCategoryEnrollmentsByUserEmail(@Param("email") String email);
}
