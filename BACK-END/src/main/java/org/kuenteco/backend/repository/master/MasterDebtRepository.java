package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.Debt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MasterDebtRepository extends JpaRepository<Debt, Integer> {}
