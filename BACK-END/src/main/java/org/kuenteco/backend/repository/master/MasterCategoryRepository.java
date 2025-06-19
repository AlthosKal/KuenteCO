package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterCategoryRepository extends JpaRepository<Category, Integer> {}
