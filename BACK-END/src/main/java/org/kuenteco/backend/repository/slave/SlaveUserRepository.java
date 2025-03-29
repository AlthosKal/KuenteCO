package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.slave.SlaveUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveUserRepository extends JpaRepository<SlaveUser, String> {
    Optional<SlaveUser> findByEmail(String email);

    Boolean existsByEmail(String email);
}
