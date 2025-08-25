package org.kuenteco.backend.dto.logic.category;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public interface CategoryEnrollmentProjection {
    int[] getCategoryEnrollmentIds();

    String getCategoryName();

    String getProfileName();

    Long getTotalEnrollments();

    LocalDateTime getFirstEnrollmentDate();

    LocalDateTime getLastEnrollmentDate();

    LocalDateTime getCategoryRegisterDate();

    BigDecimal getAssignedBudget();

    String getCategoryState();
}
