package org.kuenteco.backend.repository.slave;

import java.util.List;
import org.kuenteco.backend.entity.BudgetEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveBudgetEnrollmentRepository extends JpaRepository<BudgetEnrollment, Integer> {
    List<BudgetEnrollment> findByProfile(Profile profile);

    boolean existsByBudget_IdAndProfile_Id(Integer budgetId, Integer profileId);
}
