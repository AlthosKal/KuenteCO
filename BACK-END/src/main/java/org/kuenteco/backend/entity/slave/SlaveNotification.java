package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.slave.extra.ContentNotification;

import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "notification")
public class SlaveNotification {
    @Id
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "idAccount")
    private SlaveAccount slaveAccount;

    private Timestamp dateSend;

    @Column(columnDefinition = "JSONB")
    private ContentNotification content;
}
