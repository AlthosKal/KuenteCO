package org.kuenteco.backend.dto.logic.budget;

import java.time.LocalDateTime;

public interface BudgetEnrollmentProjection {
    int[] getBudgetEnrollmentIds();

    String getBudgetName();

    String getProfileName();

    Long getTotalEnrollments();

    LocalDateTime getFirstEnrollmentDate();

    LocalDateTime getLastEnrollmentDate();
}
