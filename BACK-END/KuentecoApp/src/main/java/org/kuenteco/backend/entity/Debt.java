package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
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
    @JoinColumn(
            name = "id_user",
            foreignKey =
                    @ForeignKey(
                            name = "fk_user",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_user) REFERENCES kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private User user;

    private String name;

    @Column(name = "total_amount")
    private BigDecimal totalAmount;

    @Column(name = "pending_amount")
    private BigDecimal pendingAmount;

    @Column(name = "start_date")
    private LocalDateTime startDate;

    @Column(name = "expiration_date")
    private LocalDateTime expirationDate;

    @Enumerated(EnumType.STRING)
    private StateDebt state;
}
