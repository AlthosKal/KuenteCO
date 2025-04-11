package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.Account;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveAccountRepository extends JpaRepository<Account, Integer> {
    Optional<Account> findByName(String name);

    Boolean existsByName(String name);

    List<Account> findByUser(User user);
}
