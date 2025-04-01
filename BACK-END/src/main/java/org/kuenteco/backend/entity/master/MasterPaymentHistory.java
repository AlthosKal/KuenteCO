package org.kuenteco.backend.entity.master;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.master.extra.DescriptionPaymentHistory;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "payment_history")
public class MasterPaymentHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idPaySubscription")
    private MasterPaySubscription masterPaySubscription;

    @Column(columnDefinition = "JSONB")
    private DescriptionPaymentHistory details;
}
