package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.slave.SlaveAccount;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveAccountRepository extends JpaRepository<SlaveAccount, Integer> {
    Optional<SlaveAccount> findByName(String name);

    Boolean existsByName(String name);

    List<SlaveAccount> findBySlaveUser(SlaveUser slaveUser);
}
