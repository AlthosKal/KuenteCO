package org.kuenteco.backend.entity.extra;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.*;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(
        name = "exchange_rate",
        uniqueConstraints = {
            @UniqueConstraint(
                    name = "uk_exchange_rate_currencies",
                    columnNames = {"base_currency", "target_currency"})
        })
public class ExchangeRate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "base_currency")
    private String baseCurrency;

    @Column(name = "target_currency")
    private String targetCurrency;

    private BigDecimal rate;

    @Column(name = "last_updated")
    private Timestamp lastUpdated;
}
