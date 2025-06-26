package org.kuenteco.backend.service.logic.budget;

import org.kuenteco.backend.dto.logic.budget.BudgetEnrollmentDTO;

public interface BudgetEnrollmentService {
    Object getAllBudgetEnrollments();

    BudgetEnrollmentDTO enrollProfileToBudget(Integer profileId, Integer budgetId);

    void removeBudgetEnrollment(Integer id);
}
