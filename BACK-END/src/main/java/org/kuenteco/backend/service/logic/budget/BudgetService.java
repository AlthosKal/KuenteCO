package org.kuenteco.backend.service.logic.budget;

import org.kuenteco.backend.dto.logic.budget.BudgetDTO;
import org.kuenteco.backend.dto.logic.budget.NewBudgetDTO;

public interface BudgetService {
    Object getBudgets();

    Object getBudgetVsActualReport();

    Object getBudgetSummary();

    void addBudget(NewBudgetDTO dto);

    void updateBudget(BudgetDTO dto);

    void deleteBudget(Integer id);
}
