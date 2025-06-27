package org.kuenteco.backend.service.logic.debt;

import java.math.BigDecimal;
import org.kuenteco.backend.dto.logic.debt.DebtDTO;
import org.kuenteco.backend.dto.logic.debt.DebtPaymentDTO;
import org.kuenteco.backend.dto.logic.debt.NewDebtDTO;
import org.kuenteco.backend.enums.StateDebt;

public interface DebtService {
    Object getDebts();

    Object getDebtsByState(StateDebt state);

    Object getOverdueDebts();

    Object getDebtsExpiringInDays(Integer days);

    BigDecimal getTotalPendingAmount();

    void addDebt(NewDebtDTO dto);

    void updateDebt(DebtDTO debtDTO);

    void makePayment(DebtPaymentDTO paymentDTO);

    void deleteDebt(Integer id);

    void updateDebtState(Integer id, StateDebt newState);
}
