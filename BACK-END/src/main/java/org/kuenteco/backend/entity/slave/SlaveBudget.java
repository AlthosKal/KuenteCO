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
    @JoinColumn(name = "id_account")
    private SlaveAccount account;

    @ManyToOne
    @JoinColumn(name = "id_category")
    private SlaveAccount category;

    private String name;

    private String description;

    @Column(name = "assigned_amount")
    private BigDecimal assignedAmount;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Column(name = "finish_date")
    private Timestamp finishDate;

    @Enumerated(EnumType.STRING)
    private State state = State.ACTIVE;
}
