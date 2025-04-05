package org.kuenteco.backend.entity.master;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.master.extra.MasterDescriptionTransaction;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "transaction")
public class MasterTransaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private MasterAccount masterAccount;

    @ManyToOne
    @JoinColumn(name = "id_category")
    private MasterCategory masterCategory;

    private String type;

    private BigDecimal amount;

    @Column(name = "transaction_date")
    private Timestamp transactionDate;

    @Column(columnDefinition = "JSONB")
    private MasterDescriptionTransaction description;
}
