package org.kuenteco.backend.entity.master;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.master.extra.MasterDescriptionCategory;
import org.kuenteco.backend.enums.State;

import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "category")
public class MasterCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private MasterAccount masterAccount;

    private String name;

    @Column(columnDefinition = "JSONB")
    private MasterDescriptionCategory description;

    @Column(name = "assigned_budget")
    private double assignedBudget;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Column(name = "finish_date")
    private Timestamp finishDate;

    @Enumerated(EnumType.STRING)
    private State state;
}
