package org.kuenteco.backend.repository.slave;

import jakarta.validation.constraints.NotBlank;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveSubscriptionRepository extends JpaRepository<Subscription, Integer> {
    Subscription findByUser(@NotBlank User user);
}
