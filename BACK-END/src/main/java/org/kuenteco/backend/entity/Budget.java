package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import lombok.*;
import org.hibernate.annotations.Check;

@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "budget")
@Check(
        constraints =
                "(id_profile IS NOT NULL AND id_user IS NULL) OR (id_profile IS NULL AND id_user IS NOT NULL)")
public class Budget {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_profile", unique = true)
    private Profile profile;

    @ManyToOne
    @JoinColumn(name = "id_user", unique = true)
    private User user;

    @Column(name = "total_budget")
    private BigDecimal totalBudget;

    @Column(name = "remaining_budget")
    private BigDecimal remainingBudget;
}
