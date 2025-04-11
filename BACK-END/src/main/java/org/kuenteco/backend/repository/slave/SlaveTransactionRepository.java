package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.enums.TransactionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveTransactionRepository extends JpaRepository<Transaction, Integer> {
    @Query("SELECT t FROM Transaction t WHERE t.account.id = :accountId")
    List<Transaction> findByAccountId(@Param("accountId") Integer accountId);

    @Query("SELECT t FROM Transaction t WHERE t.account.id = :accountId AND t.type = :type")
    List<Transaction> findByAccountIdAndType(@Param("accountId") Integer accountId,
            @Param("type") TransactionType type);

    @Query("SELECT t FROM Transaction t WHERE t.category.id = :categoryId")
    List<Transaction> findByCategoryId(@Param("categoryId") Integer categoryId);

    @Query("SELECT t FROM Transaction t WHERE t.category.id = :categoryId AND t.type = :type")
    List<Transaction> findByCategoryIdAndType(@Param("categoryId") Integer categoryId,
            @Param("type") TransactionType type);
}
