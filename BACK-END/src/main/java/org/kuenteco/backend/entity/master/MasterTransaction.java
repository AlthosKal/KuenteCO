package org.kuenteco.backend.entity.master;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.master.extra.DescriptionTransaction;

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
    @JoinColumn(name = "idAccount")
    private MasterAccount masterAccount;

    @ManyToOne
    @JoinColumn(name = "idCategory")
    private MasterCategory masterCategory;

    private String type;

    private BigDecimal amount;

    private Timestamp transactionDate;

    @Column(columnDefinition = "JSONB")
    private DescriptionTransaction description;
}
