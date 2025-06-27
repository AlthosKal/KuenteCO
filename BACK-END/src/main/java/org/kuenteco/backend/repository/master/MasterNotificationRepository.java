package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MasterNotificationRepository extends JpaRepository<Notification, Integer> {}
