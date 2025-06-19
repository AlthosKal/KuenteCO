package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.Budget;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveBudgetRepository extends JpaRepository<Budget, Integer> {}
