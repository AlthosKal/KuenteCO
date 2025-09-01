package org.kuenteco.backend.repository.slave;

import java.util.List;
import org.kuenteco.backend.dto.logic.budget.BudgetEnrollmentProjection;
import org.kuenteco.backend.entity.BudgetEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveBudgetEnrollmentRepository extends JpaRepository<BudgetEnrollment, Integer> {
    List<BudgetEnrollment> findByProfile(Profile profile);

    boolean existsByBudget_IdAndProfile_Id(Integer budgetId, Integer profileId);

    @Query(
            value =
                    """
        SELECT v.* FROM vw_budget_enrollments v
        WHERE v.owner_user_id = (SELECT id FROM kuentecouser WHERE email = :email)
        """,
            nativeQuery = true)
    List<BudgetEnrollmentProjection> findCategoryEnrollmentsByUserEmail(
            @Param("email") String email);
}
