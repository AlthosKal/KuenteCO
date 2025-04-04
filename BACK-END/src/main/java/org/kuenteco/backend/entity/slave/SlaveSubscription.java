package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.State;

import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "subscription")
public class SlaveSubscription {
    @Id
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private SlaveAccount slaveAccount;

    private String type;

    private Timestamp startDate;

    private Timestamp expirationDate;

    @Enumerated(EnumType.STRING)
    private State state;
}
