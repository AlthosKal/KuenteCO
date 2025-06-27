package org.kuenteco.backend.repository.slave;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import org.kuenteco.backend.entity.Debt;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.StateDebt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface SlaveDebtRepository extends JpaRepository<Debt, Integer> {

    @Query(
            "SELECT SUM(d.pendingAmount) FROM Debt d WHERE d.user.id = :userId AND d.state = 'ACTIVE'")
    BigDecimal getTotalPendingAmountByUser(User user);

    List<Debt> findByUser(User user);

    StateDebt getDebtsByStateAndUser(StateDebt state, User user);

    List<Debt> getDebtsByExpirationDateBeforeAndUser(Timestamp expirationDateBefore, User user);

    List<Debt> findDebtsByExpirationDate_DayAndUser(int expirationDateDay, User user);

    Debt findDebtByUser(User user);
}
