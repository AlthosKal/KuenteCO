package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.sql.Timestamp;
import lombok.*;
import org.hibernate.annotations.Check;
import org.kuenteco.backend.enums.StateDebt;

@Builder
@Getter
@Setter
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "debt")
@Check(
        constraints =
                "(id_profile IS NOT NULL AND id_user IS NULL) OR (id_profile IS NULL AND id_user IS NOT NULL)")
public class Debt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_profile", unique = true)
    private Profile profile;

    @ManyToOne
    @JoinColumn(name = "id_user", unique = true)
    private User user;

    @ManyToOne
    @JoinColumn(name = "id_transaction")
    private Transaction transaction;

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
