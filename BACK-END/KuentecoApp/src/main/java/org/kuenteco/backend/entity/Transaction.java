package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.*;
import org.hibernate.annotations.Check;
import org.hibernate.annotations.Type;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;

@Entity
@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "transaction")
@Check(
        constraints =
                "(id_profile IS NOT NULL AND id_user IS NULL) OR (id_profile IS NULL AND id_user IS NOT NULL)")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_profile",
            foreignKey = @ForeignKey(name = "fk_profile",
                    foreignKeyDefinition = "FOREIGN KEY (id_profile) REFERENCES profile(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Profile profile;

    @ManyToOne
    @JoinColumn(name = "id_user",
            foreignKey = @ForeignKey(name = "fk_user",
                    foreignKeyDefinition = "FOREIGN KEY (id_user) REFERENCES kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private User user;

    @ManyToOne
    @JoinColumn(name = "id_category",
            foreignKey = @ForeignKey(name = "fk_category",
                    foreignKeyDefinition = "FOREIGN KEY (id_category) REFERENCES category(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Category category;

    @ManyToOne
    @JoinColumn(name = "id_budget",
            foreignKey = @ForeignKey(name = "fk_budget",
                    foreignKeyDefinition = "FOREIGN KEY (id_budget) REFERENCES budget(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Budget budget;

    @ManyToOne
    @JoinColumn(name = "id_debt",
            foreignKey = @ForeignKey(name = "fk_debt",
                    foreignKeyDefinition = "FOREIGN KEY (id_debt) REFERENCES debt(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Debt debt;

    private String name;

    private BigDecimal amount;

    @Column(name = "transaction_date")
    private LocalDateTime transactionDate;

    @Type(JsonBinaryType.class)
    @Column(columnDefinition = "jsonb")
    private DescriptionTransaction description;
}
