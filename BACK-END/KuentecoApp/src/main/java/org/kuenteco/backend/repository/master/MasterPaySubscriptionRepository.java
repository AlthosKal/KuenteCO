package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.PaySubscription;
import org.kuenteco.backend.entity.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterPaySubscriptionRepository extends JpaRepository<PaySubscription, Integer> {
    PaySubscription findBySubscription(Subscription subscription);
}
