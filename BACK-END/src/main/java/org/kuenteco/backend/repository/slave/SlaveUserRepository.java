package org.kuenteco.backend.repository.slave;

import jakarta.validation.constraints.NotBlank;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.function.Supplier;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveUserRepository extends JpaRepository<SlaveUser, String> {
    Optional<SlaveUser> findByEmail(@NotBlank String email);

    Optional<SlaveUser> findByName(@NotBlank String name);

    Boolean existsByEmail(String email);

    boolean existsByName(@NotBlank String name);
}

