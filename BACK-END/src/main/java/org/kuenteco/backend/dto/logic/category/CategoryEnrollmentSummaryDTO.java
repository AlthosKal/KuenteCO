package org.kuenteco.backend.dto.logic.category;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CategoryEnrollmentSummaryDTO {
    private Integer categoryId;
    private String categoryName;
    private Integer categoryOwnerId;
    private Integer ownerUserId;
    private Long enrolledUsersCount;
    private Long enrolledProfilesCount;
    private Long totalEnrollments;
    private LocalDateTime firstEnrollmentDate;
    private LocalDateTime lastEnrollmentDate;
    private LocalDateTime categoryStartDate;
    private LocalDateTime categoryFinishDate;
    private String categoryStatus;
}
