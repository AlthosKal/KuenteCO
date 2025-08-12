package org.kuenteco.backend.repository.master;

import java.util.Optional;
import org.kuenteco.backend.entity.MercadoPagoPayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterMercadoPagoPaymentRepository extends JpaRepository<MercadoPagoPayment, Integer> {
    
    Optional<MercadoPagoPayment> findByPaymentId(String paymentId);
    
    boolean existsByPaymentId(String paymentId);
}
