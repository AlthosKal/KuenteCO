package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "user_payment_token")
public class UserPaymentToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_user")
    private User user;

    @Column(name = "wompi_token")
    private String wompiToken;

    @Column(name = "card_last_four")
    private String cardLastFour;

    @Column(name = "card_brand")
    private String cardBrand;

    @Column(name = "expiry_month")
    private String expiryMonth;

    @Column(name = "expiry_year")
    private String expiryYear;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "is_active")
    private Boolean isActive;
}
