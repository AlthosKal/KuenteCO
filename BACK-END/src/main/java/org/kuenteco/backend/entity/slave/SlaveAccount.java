package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.AccountType;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "account")
public class SlaveAccount {
    @Id
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idUser", nullable = false)
    private SlaveUser slaveUser;

    private String name;

    @Enumerated(EnumType.STRING)
    private AccountType type;

    private BigDecimal balance = BigDecimal.ZERO;

    private String currency;

    @Column(name = "start_date")
    private Timestamp startDate;
}
