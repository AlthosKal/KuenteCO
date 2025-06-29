package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
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
    private LocalDateTime payDate;

    @Embedded private PayMethodInfo payMethod;
}
