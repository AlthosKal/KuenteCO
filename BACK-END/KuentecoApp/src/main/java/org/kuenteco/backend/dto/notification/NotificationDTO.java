package org.kuenteco.backend.dto.notification;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.ContentNotification;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {

    private Integer id;

    private ContentNotification content;

    private LocalDateTime dateSend;
}
