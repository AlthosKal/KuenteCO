package org.kuenteco.backend.repository.slave;

import java.util.Optional;
import org.kuenteco.backend.entity.Role;
import org.kuenteco.backend.enums.RoleList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveRoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByName(RoleList name);
}
