package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import java.time.LocalDateTime;
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
    @JoinColumn(
            name = "id_user",
            foreignKey =
                    @ForeignKey(
                            name = "fk_user",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_user) REFERENCES kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private User user;

    @ManyToOne
    @JoinColumn(
            name = "id_profile",
            foreignKey =
                    @ForeignKey(
                            name = "fk_profile",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_profile) REFERENCES profile(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private Profile profile;

    @Column(name = "date_send")
    private LocalDateTime dateSend;

    private String title;

    @Type(JsonBinaryType.class)
    @Column(columnDefinition = "jsonb")
    private ContentNotification content;
}
