package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.UserPaymentToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveUserPaymentTokenRepository extends JpaRepository<UserPaymentToken, Integer> {
    List<UserPaymentToken> findByUserAndIsActiveTrue(User user);
    Optional<UserPaymentToken> findByIdAndUserAndIsActiveTrue(Integer id, User user);
}
