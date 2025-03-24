package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.StateDebt;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "Debt")
public class Debt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private Account account;

    private String name;

    private BigDecimal totalAmount;

    private BigDecimal pendingAmount;

    private Timestamp startDate;

    private Timestamp expirationDate;

    @Enumerated(EnumType.STRING)
    private StateDebt state;
}
