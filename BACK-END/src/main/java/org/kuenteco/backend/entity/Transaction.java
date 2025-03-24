package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "Transaction")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private Account account;

    @ManyToOne
    @JoinColumn(name = "idCategory")
    private Category category;

    private String type;

    private BigDecimal amount;

    private Timestamp transactionDate;

    @Column(columnDefinition = "JSONB")
    private DescriptionTransaction description;
}
