package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveSubscriptionRepository extends JpaRepository<Subscription, Integer> {
}
