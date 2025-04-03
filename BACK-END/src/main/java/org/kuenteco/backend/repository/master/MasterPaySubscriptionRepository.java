package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.master.MasterPaySubscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterPaySubscriptionRepository extends JpaRepository<MasterPaySubscription, Integer> {
    Optional<MasterPaySubscription> findByMasterSubscriptionId(Integer subscriptionId);
}
