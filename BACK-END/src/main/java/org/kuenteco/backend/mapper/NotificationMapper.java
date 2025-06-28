package org.kuenteco.backend.mapper;

import java.util.List;
import org.kuenteco.backend.dto.notification.NotificationDTO;
import org.kuenteco.backend.entity.Notification;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NotificationMapper {
    NotificationDTO toDTO(Notification notification);

    List<NotificationDTO> toDTOList(List<Notification> notifications);
}
