package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import java.sql.Timestamp;
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
    @JoinColumn(name = "id_user", unique = true)
    private User user;

    @OneToOne
    @JoinColumn(name = "id_budget")
    private Budget budget;

    @Type(JsonBinaryType.class)
    @Column(columnDefinition = "jsonb")
    private DescriptionCategory description;

    @Column(name = "start_date")
    private Timestamp startDate;

    @Column(name = "finish_date")
    private Timestamp finishDate;
}
