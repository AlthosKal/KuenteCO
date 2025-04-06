package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.StateInvestment;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "investment")
public class Investment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private Account account;

    private String type;

    @Column(name = "initial_amount")
    private BigDecimal initialAmount;

    private BigDecimal profitability;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Enumerated(EnumType.STRING)
    private StateInvestment state;
}
