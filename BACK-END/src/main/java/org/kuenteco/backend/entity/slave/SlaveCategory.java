package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.slave.extra.SlaveDescriptionCategory;
import org.kuenteco.backend.enums.State;

import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "category")
public class SlaveCategory {
    @Id
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private SlaveAccount slaveAccount;

    private String name;

    @Column(columnDefinition = "JSONB")
    private SlaveDescriptionCategory description;

    @Column(name = "assigned_budget")
    private double assignedBudget;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Column(name = "finish_date")
    private Timestamp finishDate;

    @Enumerated(EnumType.STRING)
    private State state;
}
