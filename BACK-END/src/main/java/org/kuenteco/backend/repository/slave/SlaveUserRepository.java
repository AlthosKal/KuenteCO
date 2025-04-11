package org.kuenteco.backend.repository.slave;

import jakarta.validation.constraints.NotBlank;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveUserRepository extends JpaRepository<User, String> {
    Optional<User> findByEmail(@NotBlank String email);

    Optional<User> findByName(@NotBlank String name);

    Boolean existsByEmail(String email);

    boolean existsByName(@NotBlank String name);
}

