package org.kuenteco.backend.repository.master;

import jakarta.validation.constraints.NotBlank;
import org.kuenteco.backend.entity.master.MasterUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterUserRepository extends JpaRepository<MasterUser, String> {
    Optional<MasterUser> findByEmail(String email);
    void removeMasterUserByEmail(@NotBlank String email);
}
