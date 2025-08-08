package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "category_enrollment")
public class CategoryEnrollment {
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
            name = "id_category",
            referencedColumnName = "id",
            foreignKey =
                    @ForeignKey(
                            name = "fk_category",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_category) REFERENCES category(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Category category;

    private LocalDateTime enrollmentDate;
}
