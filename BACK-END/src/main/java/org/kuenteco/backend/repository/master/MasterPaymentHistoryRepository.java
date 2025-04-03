package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.master.MasterPaymentHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterPaymentHistoryRepository extends JpaRepository<MasterPaymentHistory, Integer> {
}
