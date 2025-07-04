package org.kuenteco.backend.repository.slave;

import java.util.Optional;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.State;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveMercadoPagoPreapprovalRepository
        extends JpaRepository<MercadoPagoPreapproval, Integer> {
    boolean existsByUserAndSubscriptionState(User user, State state);

    Optional<MercadoPagoPreapproval> findByPreapprovalId(String preapprovalId);
}
