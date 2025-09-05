package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@Builder
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "debt_enrollment")
public class DebtEnrollment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(
            name = "id_user",
            referencedColumnName = "id",
            foreignKey =
                    @ForeignKey(
                            name = "fk_user",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_user) REFERENCES kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private User user;

    @ManyToOne
    @JoinColumn(
            name = "id_profile",
            referencedColumnName = "id",
            foreignKey =
                    @ForeignKey(
                            name = "fk_profile",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_profile) REFERENCES profile(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Profile profile;

    @ManyToOne
    @JoinColumn(
            name = "id_debt",
            referencedColumnName = "id",
            foreignKey =
                    @ForeignKey(
                            name = "fk_debt",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_debt) REFERENCES debt(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Debt debt;

    private LocalDateTime enrollmentDate;
}
