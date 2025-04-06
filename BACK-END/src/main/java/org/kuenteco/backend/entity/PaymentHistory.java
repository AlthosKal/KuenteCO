package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionPaymentHistory;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "payment_history")
public class PaymentHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_pay_subscription")
    private PaySubscription paySubscription;

    @Column(columnDefinition = "JSONB")
    private DescriptionPaymentHistory details;
}
