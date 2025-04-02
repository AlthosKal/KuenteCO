package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.slave.extra.PayMethodInfo;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "pay_subscription")
public class SlavePaySubscription {
    @Id
    private Integer id;

    @OneToOne
    @JoinColumn(name = "idSubscription")
    private SlaveSubscription slaveSubscription;

    private BigDecimal amount;

    private Timestamp payDate;

    @Embedded
    @Column(columnDefinition = "pay_method_info")
    private PayMethodInfo payMethod;
}
