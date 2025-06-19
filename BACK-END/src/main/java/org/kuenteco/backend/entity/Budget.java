package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import lombok.*;

@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "budget")
public class Budget {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "id_profile", unique = true)
    private Profile profile;

    @Column(name = "total_budget")
    private BigDecimal totalBudget;

    @Column(name = "remaining_budget")
    private BigDecimal remainingBudget;
}
