package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.Asset;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterAssetRepository extends JpaRepository<Asset, Integer> {}
