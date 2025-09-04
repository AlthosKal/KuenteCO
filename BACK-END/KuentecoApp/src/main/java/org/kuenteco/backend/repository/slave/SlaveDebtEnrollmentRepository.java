package org.kuenteco.backend.repository.slave;

import java.util.List;
import org.kuenteco.backend.dto.logic.debt.DebtEnrollmentProjection;
import org.kuenteco.backend.entity.DebtEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveDebtEnrollmentRepository extends JpaRepository<DebtEnrollment, Integer> {
    List<DebtEnrollment> findByProfile(Profile profile);

    @Query(
            value =
                    """
        SELECT v.* FROM vw_debt_enrollments v
        WHERE v.owner_user_id = (SELECT id FROM kuentecouser WHERE email = :email)
        """,
            nativeQuery = true)
    List<DebtEnrollmentProjection> findDebtEnrollmentsByUserEmail(@Param("email") String email);

    boolean existsByDebt_IdAndProfile_Id(Integer debtId, Integer profileId);
}
