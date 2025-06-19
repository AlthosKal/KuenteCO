package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.*;
import org.hibernate.annotations.Check;
import org.hibernate.annotations.Type;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.entity.extra.ExchangeRate;
import org.kuenteco.backend.enums.TransactionType;

@Entity
@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "transaction")
@Check(
        constraints =
                "(id_profile IS NOT NULL AND id_user IS NULL) OR (id_profile IS NULL AND id_user IS NOT NULL)")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_profile")
    private Profile profile;

    @ManyToOne
    @JoinColumn(name = "id_user")
    private User user;

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
