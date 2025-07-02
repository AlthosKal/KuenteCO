package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.PaySubscription;
import org.kuenteco.backend.entity.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlavePaySubscriptionRepository extends JpaRepository<PaySubscription, Integer> {
    PaySubscription findBySubscription(Subscription subscription);

    Optional<PaySubscription> findByTransactionId(String transactionId);
}
