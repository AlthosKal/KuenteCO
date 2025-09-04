package org.kuenteco.backend.dto.logic.debt;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import org.kuenteco.backend.enums.StateDebt;

public interface DebtEnrollmentProjection {
    int[] getDebtEnrollmentIds();

    String getDebtName();

    String getProfileName();

    Long getTotalEnrollments();

    BigDecimal getTotalAmount();

    BigDecimal getPendingAmount();

    LocalDateTime getStartDate();

    LocalDateTime getExpirationDate();

    StateDebt getDebtState();

    LocalDateTime getFirstEnrollmentDate();

    LocalDateTime getLastEnrollmentDate();

    Boolean getIsOverdue();

    BigDecimal getPaymentPercentage();

    Integer getDaysUntilExpiration();
}
