package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.State;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "Budget")
public class Budget {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private Account account;

    @ManyToOne
    @JoinColumn(name = "idCategory")
    private Category category;

    private String name;

    private String description;

    private BigDecimal assignedAmount;

    private Timestamp startDate;

    private Timestamp finishDate;

    @Enumerated(EnumType.STRING)
    private State state = State.ACTIVE;
}
