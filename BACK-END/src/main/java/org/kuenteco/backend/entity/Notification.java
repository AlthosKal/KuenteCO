package org.kuenteco.backend.entity;

import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Type;
import org.kuenteco.backend.entity.extra.ContentNotification;

import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "notification")
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private Account account;

    @Column(name = "date_send")
    private Timestamp dateSend;

    @Type(JsonBinaryType.class)
    @Column(columnDefinition = "jsonb")
    private ContentNotification content;
}
