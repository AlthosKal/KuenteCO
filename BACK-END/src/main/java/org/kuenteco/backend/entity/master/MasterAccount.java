package org.kuenteco.backend.entity.master;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.AccountType;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "account")
public class MasterAccount {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_user", nullable = false)
    private MasterUser masterUser;

    private String name;

    @Enumerated(EnumType.STRING)
    private AccountType type;

    private BigDecimal balance = BigDecimal.ZERO;

    private String currency;

    @Column(name = "start_date")
    private Timestamp startDate;

}
