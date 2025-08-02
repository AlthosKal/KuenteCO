package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "subscription")
public class Subscription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "id_user",
            foreignKey = @ForeignKey(name = "fk_user",
                    foreignKeyDefinition = "FOREIGN KEY (id_user) REFERENCES kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private User user;

    @Enumerated(EnumType.STRING)
    private SubscriptionType type;

    @Column(name = "start_date")
    private LocalDateTime startDate;

    @Column(name = "expiration_date")
    private LocalDateTime expirationDate;

    @Enumerated(EnumType.STRING)
    private State state;

    // Relación con MercadoPago Preapproval
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_mercadopago_preapproval")
    private MercadoPagoPreapproval mercadoPagoPreapproval;

    @Column(name = "is_auto_renewable")
    private Boolean isAutoRenewable;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
