package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.slave.extra.DescriptionPaymentHistory;

@Data
@Entity
@NoArgsConstructor
@Table(name = "payment_history")
public class SlavePaymentHistory {
    @Id
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_pay_subscription")
    private SlavePaySubscription slavePaySubscription;

    @Column(columnDefinition = "JSONB")
    private DescriptionPaymentHistory details;
}
