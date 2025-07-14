package org.kuenteco.backend.repository.slave;

import java.util.List;
import java.util.Optional;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveProfileRepository extends JpaRepository<Profile, Integer> {

    Boolean existsByUsername(String name);

    List<Profile> findByUser(User user);

    Optional<Profile> findByEmail(String email);

    Optional<Profile> findByUsername(String name);

    boolean existsByEmail(String email);
}
