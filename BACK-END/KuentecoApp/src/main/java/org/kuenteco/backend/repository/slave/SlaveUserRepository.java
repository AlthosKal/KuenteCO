package org.kuenteco.backend.repository.slave;

import jakarta.validation.constraints.NotBlank;
import java.util.Optional;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveUserRepository extends JpaRepository<User, String> {
    Optional<User> findByEmail(@NotBlank String email);

    Optional<User> findByUsername(@NotBlank String username);

    Boolean existsByEmail(String email);

    boolean existsByUsername(@NotBlank String username);
}
