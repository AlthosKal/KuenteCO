package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.StateDebt;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "debt")
public class SlaveDebt {
    @Id
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private SlaveAccount slaveAccount;

    private String name;

    private BigDecimal totalAmount;

    private BigDecimal pendingAmount;

    private Timestamp startDate;

    private Timestamp expirationDate;

    @Enumerated(EnumType.STRING)
    private StateDebt state;
}
