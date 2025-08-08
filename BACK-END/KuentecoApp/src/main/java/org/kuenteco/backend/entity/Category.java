package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.*;
import org.hibernate.annotations.Type;
import org.kuenteco.backend.entity.extra.DescriptionCategory;

@Builder
@Getter
@Setter
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "category")
public class Category {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(
            name = "id_user",
            nullable = false,
            foreignKey =
                    @ForeignKey(
                            name = "fk_user",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_user) REFERENCES kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private User user;

    @ManyToOne
    @JoinColumn(
            name = "id_budget",
            foreignKey =
                    @ForeignKey(
                            name = "fk_budget",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_budget) REFERENCES budget(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Budget budget;

    private String name;

    @Type(JsonBinaryType.class)
    @Column(columnDefinition = "jsonb")
    private DescriptionCategory description;

    @Column(name = "start_date")
    private LocalDateTime startDate;

    @Column(name = "finish_date")
    private LocalDateTime finishDate;
}
