package org.kuenteco.backend.entity.master;

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
@Table(name = "budget")
public class MasterBudget {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private MasterAccount masterAccount;

    @ManyToOne
    @JoinColumn(name = "idCategory")
    private MasterCategory masterCategory;

    private String name;

    private String description;

    private BigDecimal assignedAmount;

    private Timestamp startDate;

    private Timestamp finishDate;

    @Enumerated(EnumType.STRING)
    private State state = State.ACTIVE;
}
