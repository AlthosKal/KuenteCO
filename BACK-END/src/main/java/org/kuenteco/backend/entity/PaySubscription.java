package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.*;
import org.kuenteco.backend.entity.extra.PayMethodInfo;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "pay_subscription")
public class PaySubscription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "id_subscription")
    private Subscription subscription;

    private BigDecimal amount;

    @Column(name = "pay_date")
    private Timestamp payDate;

    @Embedded private PayMethodInfo payMethod;
}
