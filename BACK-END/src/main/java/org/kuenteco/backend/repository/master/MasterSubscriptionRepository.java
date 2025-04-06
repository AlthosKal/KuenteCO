package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.master.MasterSubscription;
import org.kuenteco.backend.enums.State;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterSubscriptionRepository extends JpaRepository<MasterSubscription, Integer> {
    Optional<MasterSubscription> findByMasterAccount_IdAndState(Integer masterAccountId, State state);
}
