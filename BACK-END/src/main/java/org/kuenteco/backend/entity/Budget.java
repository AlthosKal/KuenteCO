package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@Entity
@Table(name = "budget")
public class Budget {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "id_account", unique = true)
    private Account account;

    @Column(name = "total_budget")
    private BigDecimal totalBudget;

    @Column(name = "remaining_budget")
    private BigDecimal remainingBudget;
}
