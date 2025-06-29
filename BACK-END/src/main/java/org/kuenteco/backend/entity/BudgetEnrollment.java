package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@Builder
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "budget_enrollment")
public class BudgetEnrollment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_user", referencedColumnName = "id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "id_profile", referencedColumnName = "id")
    private Profile profile;

    @ManyToOne
    @JoinColumn(name = "id_budget", referencedColumnName = "id")
    private Budget budget;

    private LocalDateTime enrollmentDate;
}
