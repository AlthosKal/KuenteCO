package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.slave.extra.SlavePayMethodInfo;

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
    @JoinColumn(name = "id_subscription")
    private SlaveSubscription slaveSubscription;

    private BigDecimal amount;

    @Column(name = "pay_date")
    private Timestamp payDate;

    @Embedded
    @Column(columnDefinition = "pay_method_info")
    private SlavePayMethodInfo payMethod;
}
