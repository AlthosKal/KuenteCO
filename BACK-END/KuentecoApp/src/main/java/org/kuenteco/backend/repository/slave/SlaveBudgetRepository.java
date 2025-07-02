package org.kuenteco.backend.repository.slave;

import java.util.List;
import org.kuenteco.backend.dto.logic.budget.BudgetSummaryDTO;
import org.kuenteco.backend.dto.logic.budget.BudgetVsActualDTO;
import org.kuenteco.backend.entity.Budget;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveBudgetRepository extends JpaRepository<Budget, Integer> {
    List<Budget> findByUser(User user);

    Budget findBudgetByUser(User user);

    @Query(
            value =
                    """
    SELECT v.* FROM vw_budget_vs_actual v
    JOIN kuentecouser u ON v.owner_user_id = u.id
    WHERE u.email = :email
    """,
            nativeQuery = true)
    List<BudgetVsActualDTO> findAllBudgetVsActual(@Param("email") String email);

    @Query(
            value =
                    """
SELECT v.* FROM vw_budget_summary_by_user v
WHERE v.owner_user_id = (SELECT id FROM kuentecouser WHERE email = :email)
""",
            nativeQuery = true)
    List<BudgetSummaryDTO> getBudgetSummaries(@Param("email") String email);
}
