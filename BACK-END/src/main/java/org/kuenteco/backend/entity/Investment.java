package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.*;
import org.kuenteco.backend.enums.StateInvestment;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "investment")
public class Investment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_profile")
    private Profile profile;

    private String type;

    @Column(name = "initial_amount")
    private BigDecimal initialAmount;

    private BigDecimal profitability;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Enumerated(EnumType.STRING)
    private StateInvestment state;
}
