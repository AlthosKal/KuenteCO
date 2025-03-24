package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.enums.State;

import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "Category")
public class Category {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private Account account;

    private String name;

    @Column(columnDefinition = "JSONB")
    private DescriptionCategory description;

    private double assignedBudget;

    private Timestamp startDate;

    private Timestamp finishDate;

    @Enumerated(EnumType.STRING)
    private State state;
}
