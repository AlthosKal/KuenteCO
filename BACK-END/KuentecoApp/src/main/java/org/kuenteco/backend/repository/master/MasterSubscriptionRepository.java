package org.kuenteco.backend.repository.master;

import java.util.Optional;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.State;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterSubscriptionRepository extends JpaRepository<Subscription, Integer> {
    Optional<Subscription> findByUserAndState(User user, State state);

    Optional<Subscription> findByUser(User user);
}
