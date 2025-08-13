package org.kuenteco.backend.repository.slave;

import java.util.List;
import java.util.Optional;
import org.kuenteco.backend.entity.MercadoPagoPayment;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveMercadoPagoPaymentRepository
        extends JpaRepository<MercadoPagoPayment, Integer> {
    List<MercadoPagoPayment> findByPreapprovalOrderByDateCreatedDesc(
            MercadoPagoPreapproval preapproval);
            
    Optional<MercadoPagoPayment> findByPaymentId(String paymentId);
}
