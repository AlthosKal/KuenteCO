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
    @JoinColumn(name = "id_account")
    private SlaveAccount masterAccount;

    private String name;

    @Column(name = "total_amount")
    private BigDecimal totalAmount;

    @Column(name = "pending_amount")
    private BigDecimal pendingAmount;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Column(name = "expiration_date")
    private Timestamp expirationDate;

    @Enumerated(EnumType.STRING)
    private StateDebt state;
}
