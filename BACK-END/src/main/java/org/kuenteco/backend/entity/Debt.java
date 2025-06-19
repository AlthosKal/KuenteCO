package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.*;
import org.kuenteco.backend.enums.StateDebt;

@Builder
@Getter
@Setter
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "debt")
public class Debt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_profile")
    private Profile profile;

    private String name;

    @Column(name = "total_amount")
    private BigDecimal totalAmount;

    @Column(name = "pending_amount")
    private BigDecimal pendingAmount;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Column(name = "expiration_date")
    private Timestamp expirationDate;

    @Enumerated(EnumType.STRING)
    private StateDebt state;
}
