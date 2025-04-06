package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.Image;
import org.kuenteco.backend.enums.AccountType;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "account")
public class Account {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_user", nullable = false)
    private User user;

    private String name;

    @Enumerated(EnumType.STRING)
    private AccountType type;

    private BigDecimal balance = BigDecimal.ZERO;

    private String currency;

    @Column(name = "start_date")
    private Timestamp startDate;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "id_image", referencedColumnName = "id")
    private Image image;
}
