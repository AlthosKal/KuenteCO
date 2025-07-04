package org.kuenteco.backend.repository.master;

import jakarta.validation.constraints.NotBlank;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterUserRepository extends JpaRepository<User, String> {
    void removeUserByEmail(@NotBlank String email);
}
