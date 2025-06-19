package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.*;
import org.kuenteco.backend.enums.GoalType;
import org.kuenteco.backend.enums.State;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "goal")
public class Goal {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_profile")
    private Profile profile;

    @ManyToOne
    @JoinColumn(name = "id_category")
    private Category category;

    private String name;

    private String description;

    @Column(name = "assigned_amount")
    private BigDecimal assignedAmount;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Column(name = "finish_date")
    private Timestamp finishDate;

    @Enumerated(EnumType.STRING)
    private State state;

    @Column(name = "goal_type")
    @Enumerated(EnumType.STRING)
    private GoalType goalType;
}
