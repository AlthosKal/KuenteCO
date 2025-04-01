package org.kuenteco.backend.entity.master;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.master.extra.PayMethodInfo;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "pay_subscription")
public class MasterPaySubscription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "idSubscription")
    private MasterSubscription masterSubscription;

    private BigDecimal amount;

    private Timestamp payDate;

    @Embedded
    @Column(columnDefinition = "pay_method_info")
    private PayMethodInfo payMethod;
}
