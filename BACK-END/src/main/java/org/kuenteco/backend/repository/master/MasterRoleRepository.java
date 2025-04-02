package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.master.MasterRole;
import org.kuenteco.backend.enums.RoleList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterRoleRepository extends JpaRepository<MasterRole, Integer> {
    Optional<MasterRole> findByName(RoleList name);
}
