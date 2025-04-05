package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.slave.extra.SlaveDescriptionTransaction;

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
    @JoinColumn(name = "id_account")
    private SlaveTransaction masterAccount;

    @ManyToOne
    @JoinColumn(name = "id_category")
    private SlaveCategory masterCategory;

    private String type;

    private BigDecimal amount;

    @Column(name = "transaction_date")
    private Timestamp transactionDate;

    @Column(columnDefinition = "JSONB")
    private SlaveDescriptionTransaction description;
}
