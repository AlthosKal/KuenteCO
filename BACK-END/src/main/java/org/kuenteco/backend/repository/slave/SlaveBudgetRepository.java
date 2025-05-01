package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.Budget;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveBudgetRepository extends JpaRepository<Budget, Integer> {
    @Query("SELECT b FROM Budget b WHERE b.account.id = :accountId")
    Optional<Budget> findByAccountId(@Param("accountId") Integer accountId);
}
