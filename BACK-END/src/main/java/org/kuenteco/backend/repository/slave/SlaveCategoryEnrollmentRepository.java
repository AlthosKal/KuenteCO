package org.kuenteco.backend.repository.slave;

import java.util.List;
import org.kuenteco.backend.entity.CategoryEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveCategoryEnrollmentRepository
        extends JpaRepository<CategoryEnrollment, Integer> {
    List<CategoryEnrollment> findByProfile(Profile profile);

    boolean existsByCategoryIdAndProfile_Id(Integer categoryId, Integer profileId);
}
