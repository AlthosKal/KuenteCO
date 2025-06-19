package org.kuenteco.backend.repository.master;

import java.util.Optional;
import org.kuenteco.backend.entity.Role;
import org.kuenteco.backend.enums.RoleList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterRoleRepository extends JpaRepository<Role, Integer> {
    Optional<Role> findByName(RoleList name);
}
