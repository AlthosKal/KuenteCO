package org.kuenteco.backend.repository;

import org.kuenteco.backend.entity.Account;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Integer> {
    Optional<Account> findByName(String name);

    Boolean existsByName(String name);

    List<Account> findByUser(User user);
}
