package org.kuenteco.backend.repository.master;


import org.kuenteco.backend.entity.UserPaymentToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterUserPaymentTokenRepository extends JpaRepository<UserPaymentToken, Integer> {
}
