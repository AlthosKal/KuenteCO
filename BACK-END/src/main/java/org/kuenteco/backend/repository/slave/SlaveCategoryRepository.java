package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.enums.State;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveCategoryRepository extends JpaRepository<Category, Integer> {
    @Query("SELECT c FROM Category c WHERE c.account.id = :accountId")
    List<Category> findByAccountId(@Param("accountId") Integer accountId);

    @Query("SELECT c FROM Category c WHERE c.account.id = :accountId AND c.state = :state")
    List<Category> findByAccountIdAndState(@Param("accountId") Integer accountId, @Param("state") State state);

    @Query("SELECT c FROM Category c WHERE c.asset.id = :assetId")
    List<Category> findByAssetId(@Param("assetId") Integer assetId);
}
