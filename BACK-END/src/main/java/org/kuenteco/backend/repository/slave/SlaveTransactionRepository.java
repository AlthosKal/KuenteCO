package org.kuenteco.backend.repository.slave;

import java.util.List;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveTransactionRepository extends JpaRepository<Transaction, Integer> {
    List<Transaction> findByUser(User user);

    List<Transaction> findByCategoryOrderByTransactionDateDesc(Category category);

    List<Transaction> findByProfile(Profile profile);
}
