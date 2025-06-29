package org.kuenteco.backend.repository.slave;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import org.kuenteco.backend.entity.Debt;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.StateDebt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveDebtRepository extends JpaRepository<Debt, Integer> {
    @Query(
            """
    SELECT COALESCE(SUM(d.pendingAmount), 0) FROM Debt d WHERE d.user = :user AND d.state = :state""")
    BigDecimal sumPendingAmountByStateAndUser(
            @Param("state") StateDebt state, @Param("user") User user);

    List<Debt> findByUser(User user);

    List<Debt> findByStateAndUser(StateDebt state, User user);

    List<Debt> getDebtsByExpirationDateBeforeAndUser(LocalDateTime expirationDateBefore, User user);

    List<Debt> findByUserAndExpirationDateBetween(
            User user, LocalDateTime start, LocalDateTime end);

    Debt findDebtByUser(User user);
}
