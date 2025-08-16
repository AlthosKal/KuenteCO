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
    // Obtiene todas las suscripciones de un usuario
    List<Subscription> findByUser(User user);

    // Obtiene la suscripción más reciente del usuario (ordenada por ID descendente)
    Optional<Subscription> findFirstByUserOrderByIdDesc(User user);

    // Obtiene todas las suscripciones de un usuario por estado específico
    List<Subscription> findByUserAndState(User user, State state);

    // Método para obtener la suscripción "actual" del usuario (la más reciente)
    default Optional<Subscription> getSubscriptionByUser(User user) {
        return findFirstByUserOrderByIdDesc(user);
    }
}
