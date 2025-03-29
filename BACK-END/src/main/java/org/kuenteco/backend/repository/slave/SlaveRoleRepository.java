package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.slave.SlaveRole;
import org.kuenteco.backend.enums.RoleList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveRoleRepository extends JpaRepository<SlaveRole, Long> {
    Optional<SlaveRole> findByName(RoleList name);
}
