package org.kuenteco.backend.dto.logic.category;

import java.time.LocalDateTime;

public interface CategoryEnrollmentProjection {
    Integer getCategoryId();

    String getCategoryName();

    String getCategoryOwnerId();

    String getOwnerUserId(); // <-- es String (UUID como texto)

    Long getEnrolledUsersCount();

    Long getEnrolledProfilesCount();

    Long getTotalEnrollments();

    LocalDateTime getFirstEnrollmentDate();

    LocalDateTime getLastEnrollmentDate();

    LocalDateTime getCategoryStartDate();

    LocalDateTime getCategoryFinishDate();

    String getCategoryStatus();
}
