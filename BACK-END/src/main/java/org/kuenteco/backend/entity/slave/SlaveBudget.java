package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.State;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "budget")
public class SlaveBudget {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private SlaveAccount account;

    @ManyToOne
    @JoinColumn(name = "idCategory")
    private SlaveAccount category;

    private String name;

    private String description;

    private BigDecimal assignedAmount;

    private Timestamp startDate;

    private Timestamp finishDate;

    @Enumerated(EnumType.STRING)
    private State state = State.ACTIVE;
}
