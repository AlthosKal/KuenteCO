package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.PayMethodInfo;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "PaySubscription")
public class PaySubscription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "idSubscription")
    private Subscription subscription;

    private BigDecimal amount;

    private Timestamp payDate;

    @Embedded
    @Column(columnDefinition = "pay_method_info")
    private PayMethodInfo payMethod;
}
