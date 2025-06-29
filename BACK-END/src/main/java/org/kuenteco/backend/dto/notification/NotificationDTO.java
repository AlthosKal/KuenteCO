package org.kuenteco.backend.dto.notification;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.ContentNotification;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {

    @NotNull(message = "El ID de la notificación es obligatorio")
    private Integer id;

    /*
        private String userId;

        private Integer profileId;
    */
    @NotNull(message = "El contenido de la notificación es obligatorio")
    private ContentNotification content;

    @NotNull(message = "La fecha de envío es obligatoria")
    private LocalDateTime dateSend;
}
