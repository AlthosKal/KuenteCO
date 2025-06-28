package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import java.sql.Timestamp;
import lombok.*;
import org.hibernate.annotations.Check;
import org.hibernate.annotations.Type;
import org.kuenteco.backend.entity.extra.ContentNotification;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "notification")
@Check(
        constraints =
                "(id_profile IS NOT NULL AND id_user IS NULL) OR (id_profile IS NULL AND id_user IS NOT NULL)")
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_user")
    private User user;

    @ManyToOne
    @JoinColumn(name = "id_profile")
    private Profile profile;

    @Column(name = "date_send")
    private Timestamp dateSend;

    private String title;

    @Type(JsonBinaryType.class)
    @Column(columnDefinition = "jsonb")
    private ContentNotification content;
}
