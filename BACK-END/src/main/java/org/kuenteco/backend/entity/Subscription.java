package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.sql.Timestamp;
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

    @ManyToOne
    @JoinColumn(name = "id_user")
    private User user;

    @Enumerated(EnumType.STRING)
    private SubscriptionType type;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Column(name = "expiration_date")
    private Timestamp expirationDate;

    @Enumerated(EnumType.STRING)
    private State state;
}
