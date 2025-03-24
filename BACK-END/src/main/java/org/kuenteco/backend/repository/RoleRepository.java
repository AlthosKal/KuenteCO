package org.kuenteco.backend.repository;

import org.kuenteco.backend.entity.Role;
import org.kuenteco.backend.enums.RoleList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByName(RoleList name);
}