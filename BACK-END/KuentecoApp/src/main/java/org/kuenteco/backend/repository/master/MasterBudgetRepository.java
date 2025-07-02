package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.Budget;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterBudgetRepository extends JpaRepository<Budget, Integer> {}
