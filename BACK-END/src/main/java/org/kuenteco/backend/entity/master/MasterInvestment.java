package org.kuenteco.backend.entity.master;

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
public class MasterInvestment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private MasterAccount masterAccount;

    private String type;

    private BigDecimal initialAmount;

    private BigDecimal profitability;

    private Timestamp startDate;

    @Enumerated(EnumType.STRING)
    private StateInvestment state;
}
