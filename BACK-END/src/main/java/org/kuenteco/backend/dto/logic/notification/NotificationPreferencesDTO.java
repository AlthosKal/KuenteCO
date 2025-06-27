package org.kuenteco.backend.dto.logic.notification;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationPreferencesDTO {

    private String userId;

    private Integer profileId;

    // Preferencias de notificaciones de presupuesto
    private boolean budgetExceededEnabled = true;
    private boolean budgetNearLimitEnabled = true;

    // Preferencias de notificaciones de deudas
    private boolean debtReminderEnabled = true;
    private boolean debtOverdueEnabled = true;
    private int debtReminderDaysBefore = 3;

    // Preferencias de notificaciones de transacciones
    private boolean transactionAlertEnabled = false;
    private boolean unusualActivityEnabled = true;

    // Canales de notificación
    private boolean emailEnabled = true;
    private boolean pushEnabled = true;
    private boolean smsEnabled = false;

    // Email para notificaciones (si es diferente al principal)
    private String notificationEmail;

    // Número de teléfono para SMS
    private String phoneNumber;
}
