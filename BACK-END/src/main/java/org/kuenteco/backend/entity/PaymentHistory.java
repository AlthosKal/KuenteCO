package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Type;
import org.kuenteco.backend.entity.extra.DescriptionPaymentHistory;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "PaymentHistory")
public class PaymentHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idPaySubscription")
    private PaySubscription paySubscription;

    @Column(columnDefinition = "JSONB")
    private DescriptionPaymentHistory details;
}
