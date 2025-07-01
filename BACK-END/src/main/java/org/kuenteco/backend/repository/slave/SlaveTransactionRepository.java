package org.kuenteco.backend.repository.slave;

import java.util.List;

import org.kuenteco.backend.dto.logic.transaction.TransactionSummaryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveTransactionRepository extends JpaRepository<Transaction, Integer> {
    List<Transaction> findByUser(User user);

    List<Transaction> findByCategoryOrderByTransactionDateDesc(Category category);

    List<Transaction> findByProfile(Profile profile);

    @Query(value = """
    SELECT v.* FROM vw_transactions_summary v
    JOIN kuentecouser u ON v.owner_user_id = u.id
    WHERE u.email = :email
    """, nativeQuery = true)
    List<TransactionSummaryDTO> findAllTransactionsSummaries(@Param("email") String email);
}