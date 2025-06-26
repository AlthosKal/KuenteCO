package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.BudgetEnrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MasterBudgetEnrollmentRepository
        extends JpaRepository<BudgetEnrollment, Integer> {}
