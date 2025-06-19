package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveTransactionRepository extends JpaRepository<Transaction, Integer> {}
