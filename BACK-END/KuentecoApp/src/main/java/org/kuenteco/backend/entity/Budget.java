package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import lombok.*;

@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "budget")
public class Budget {
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

    @Column(name = "total_budget")
    private BigDecimal totalBudget;

    @Column(name = "remaining_budget")
    private BigDecimal remainingBudget;
}
