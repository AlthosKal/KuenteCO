package org.kuenteco.backend.repository.slave;

import java.util.List;
import java.util.Optional;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.State;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveSubscriptionRepository extends JpaRepository<Subscription, Integer> {
    Optional<Subscription> findByUser(User user);

    Optional<Subscription> findFirstByUserOrderByIdDesc(User user);

    List<Subscription> findByUserAndState(User user, State state);

    Optional<Subscription> getSubscriptionByUser(User user);
}
