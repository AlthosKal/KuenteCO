package org.kuenteco.backend.repository.master;

import jakarta.validation.constraints.NotBlank;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterUserRepository extends JpaRepository<User, String> {
    Optional<User> findByName(@NotBlank String name);
    Optional<User> findByEmail(String email);

    void removeUserByEmail(@NotBlank String email);
}
