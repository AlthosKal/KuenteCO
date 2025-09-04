package org.kuenteco.backend.service.logic.debt;

import org.kuenteco.backend.dto.logic.debt.DebtEnrollmentDTO;

public interface DebtEnrollmentService {
    Object getAllDebtEnrollments();

    Object getBusinessUserDebtEnrollments();

    DebtEnrollmentDTO enrollProfileToDebt(Integer profileId, Integer debtId);

    void removeDebtEnrollment(Integer id);
}
