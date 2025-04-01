package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.StateInvestment;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "investment")
public class SlaveInvestment {
    @Id
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private SlaveAccount slaveAccount;

    private String type;

    private BigDecimal initialAmount;

    private BigDecimal profitability;

    private Timestamp startDate;

    @Enumerated(EnumType.STRING)
    private StateInvestment state;
}
