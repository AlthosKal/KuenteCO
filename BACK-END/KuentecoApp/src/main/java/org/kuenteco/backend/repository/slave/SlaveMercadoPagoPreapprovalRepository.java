package org.kuenteco.backend.repository.slave;

import java.util.Optional;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveMercadoPagoPreapprovalRepository
        extends JpaRepository<MercadoPagoPreapproval, Integer> {

    Optional<MercadoPagoPreapproval> findByPreapprovalId(String preapprovalId);

    // Obtiene el preapproval más reciente del usuario
    Optional<MercadoPagoPreapproval> findFirstByUserOrderByIdDesc(User user);

    // Mantener compatibilidad usando el más reciente
    default Optional<MercadoPagoPreapproval> findByUser(User user) {
        return findFirstByUserOrderByIdDesc(user);
    }

    Optional<MercadoPagoPreapproval> findByExternalReference(String externalReference);
}
