package org.kuenteco.backend.repository.master;

import java.util.Optional;
import org.kuenteco.backend.entity.PaySubscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterPaySubscriptionRepository extends JpaRepository<PaySubscription, Integer> {
    Optional<PaySubscription> findBySubscriptionId(Integer subscriptionId);
}
