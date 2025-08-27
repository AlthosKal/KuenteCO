package org.kuenteco.backend.service.webhook;

import java.util.Map;
import org.springframework.scheduling.annotation.Async;
import org.springframework.transaction.annotation.Transactional;

/** Servicio para procesar webhooks de MercadoPago */
public interface MercadoPagoWebhookService {

    @Async
    @Transactional
    void processSubscriptionAuthorizedPaymentWebhook(
            String paymentId, String action, Map<String, Object> notification);

    /**
     * Procesa webhooks de preapproval (suscripciones)
     *
     * @param preapprovalId ID del preapproval
     * @param action Acción del webhook (authorized, pending, cancelled, etc.)
     * @param notification Datos completos de la notificación
     */
    void processPreapprovalWebhook(
            String preapprovalId, String action, Map<String, Object> notification);

    /**
     * Procesa webhooks de pagos individuales
     *
     * @param paymentId ID del pago
     * @param action Acción del webhook (payment.created, payment.updated, etc.)
     * @param notification Datos completos de la notificación
     */
    void processPaymentWebhook(String paymentId, String action, Map<String, Object> notification);

    /**
     * Procesa webhooks genéricos
     *
     * @param notification Datos completos de la notificación
     */
    void processGenericWebhook(Map<String, Object> notification);

    /**
     * Valida que el webhook proviene realmente de MercadoPago
     *
     * @param notification Datos de la notificación
     * @param headers Headers HTTP de la petición
     * @return true si es válido, false si no
     */
    boolean isValidWebhook(Map<String, Object> notification, Map<String, String> headers);
}
