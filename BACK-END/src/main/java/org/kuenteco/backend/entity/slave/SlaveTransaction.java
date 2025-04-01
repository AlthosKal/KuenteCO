package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.slave.extra.DescriptionTransaction;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "transaction")
public class SlaveTransaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private SlaveAccount slaveAccount;

    @ManyToOne
    @JoinColumn(name = "idCategory")
    private SlaveCategory slaveCategory;

    private String type;

    private BigDecimal amount;

    private Timestamp transactionDate;

    @Column(columnDefinition = "JSONB")
    private DescriptionTransaction description;
}
