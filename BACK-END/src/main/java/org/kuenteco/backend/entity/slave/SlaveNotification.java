package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.master.MasterAccount;
import org.kuenteco.backend.entity.slave.extra.SlaveContentNotification;

import java.sql.Timestamp;

@Data
@Entity
@NoArgsConstructor
@Table(name = "notification")
public class SlaveNotification {
    @Id
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private SlaveAccount masterAccount;

    @Column(name = "date_send")
    private Timestamp dateSend;

    @Column(columnDefinition = "JSONB")
    private SlaveContentNotification content;
}
