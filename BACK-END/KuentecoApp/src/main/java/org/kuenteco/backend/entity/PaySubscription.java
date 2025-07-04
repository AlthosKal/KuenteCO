package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.*;
import org.hibernate.annotations.Type;
import org.kuenteco.backend.entity.extra.PayMethodInfo;
import org.kuenteco.backend.enums.PaymentStatus;

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

    @Column(name = "transaction_id")
    private String transactionId; // ID de la transacción en Wompi

    private BigDecimal amount;

    @Column(name = "pay_date")
    private LocalDateTime payDate;

    @Enumerated(EnumType.STRING)
    private PaymentStatus status;

    @Type(JsonBinaryType.class)
    @Column(columnDefinition = "jsonb")
    private PayMethodInfo payMethod;
}
