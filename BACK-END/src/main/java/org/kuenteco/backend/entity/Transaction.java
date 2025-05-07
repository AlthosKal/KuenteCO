package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Type;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.entity.extra.ExchangeRate;
import org.kuenteco.backend.enums.TransactionType;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "transaction")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private Account account;

    @ManyToOne
    @JoinColumn(name = "id_category")
    private Category category;

    @Enumerated(EnumType.STRING)
    private TransactionType type;

    private BigDecimal amount;

    @Column(name = "transaction_date")
    private Timestamp transactionDate;

    @Type(JsonBinaryType.class)
    @Column(columnDefinition = "jsonb")
    private DescriptionTransaction description;

    @ManyToOne
    @JoinColumn(name = "id_debt")
    private Debt relatedDebt; // Para pagos de deuda

    @ManyToOne
    @JoinColumn(name = "id_goal")
    private Goal relatedGoal; // Para contribuciones a metas

    @ManyToOne
    @JoinColumn(name = "id_exchange_rate")
    private ExchangeRate exchangeRate;
}
