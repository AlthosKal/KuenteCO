package org.kuenteco.backend.dto.logic.notification;

import jakarta.validation.constraints.NotNull;
import java.sql.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.ContentNotification;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewNotificationDTO {

    private String userId;

    private Integer profileId;

    @NotNull(message = "El contenido de la notificación es obligatorio")
    private ContentNotification content;

    private Timestamp dateSend = new Timestamp(System.currentTimeMillis());
}
