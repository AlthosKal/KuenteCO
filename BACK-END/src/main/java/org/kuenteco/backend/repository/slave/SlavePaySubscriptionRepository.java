package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.slave.SlavePaySubscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlavePaySubscriptionRepository extends JpaRepository<SlavePaySubscription, Integer> {
    Optional<SlavePaySubscription> findBySlaveSubscriptionId(Integer integer);
}
