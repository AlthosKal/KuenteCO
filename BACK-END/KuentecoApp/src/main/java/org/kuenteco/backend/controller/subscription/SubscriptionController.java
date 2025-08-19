package org.kuenteco.backend.controller.subscription;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.subscription.request.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.PaymentHistoryResponseDTO;
import org.kuenteco.backend.dto.subscription.response.SubscriptionResponseDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.subscription.MercadoPagoPaymentService;
import org.kuenteco.backend.service.subscription.MercadoPagoService;
import org.kuenteco.backend.service.webhook.MercadoPagoWebhookService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/v1/subscription")
@RequiredArgsConstructor
public class SubscriptionController implements SubscriptionResource {

    private final MercadoPagoService mercadoPagoService;
    private final MercadoPagoPaymentService mercadoPagoPaymentService;
    private final MercadoPagoWebhookService mercadoPagoWebhookService;

    /**
     * Crea una nueva suscripción en Mercado Pago
     *
     * @param dto DTO con los datos de la suscripción a crear
     * @param principal Información del usuario autenticado
     * @param request Información de la petición HTTP
     * @return Respuesta con los datos de la suscripción creada
     */
    @PostMapping("/add")
    public ResponseEntity<?> createSubscription(
            @Valid @RequestBody CreateSubscriptionRequestDTO dto,
            Principal principal,
            HttpServletRequest request) {

        String userEmail = principal.getName();
        log.info(
                "Creando suscripción tipo {} para usuario: {}",
                dto.getSubscriptionType(),
                userEmail);

        try {
            CreateSubscriptionResponseDTO response =
                    mercadoPagoService.createSubscription(dto, userEmail);

            log.info(
                    "Suscripción creada exitosamente para usuario: {}, preapproval ID: {}",
                    userEmail,
                    response.getPreapprovalId());

            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Suscripción creada exitosamente", response, request.getRequestURI()),
                    HttpStatus.CREATED);

        } catch (Exception e) {
            log.error(
                    "Error al crear suscripción para usuario {}: {}", userEmail, e.getMessage(), e);
            throw e; // Re-lanzar para que sea manejado por el GlobalExceptionHandler
        }
    }

    /**
     * Obtiene los detalles de una suscripción específica
     *
     * @param preapprovalId ID de la preaprobación de Mercado Pago
     * @param principal Información del usuario autenticado
     * @param request Información de la petición HTTP
     * @return Respuesta con los detalles de la suscripción
     */
    @GetMapping("/{preapprovalId}")
    public ResponseEntity<?> getSubscription(
            @PathVariable String preapprovalId, Principal principal, HttpServletRequest request) {

        String userEmail = principal.getName();
        log.info("Obteniendo suscripción {} para usuario: {}", preapprovalId, userEmail);

        try {
            SubscriptionResponseDTO response =
                    mercadoPagoService.getSubscription(preapprovalId, userEmail);

            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Suscripción obtenida exitosamente", response, request.getRequestURI()),
                    HttpStatus.OK);

        } catch (Exception e) {
            log.error(
                    "Error al obtener suscripción {} para usuario {}: {}",
                    preapprovalId,
                    userEmail,
                    e.getMessage(),
                    e);
            throw e; // Re-lanzar para que sea manejado por el GlobalExceptionHandler
        }
    }

    /**
     * Obtiene el historial de pagos de una suscripción específica
     *
     * @param preapprovalId ID de la preaprobación de Mercado Pago
     * @param principal Información del usuario autenticado
     * @param request Información de la petición HTTP
     * @return Respuesta con el historial de pagos
     */
    @GetMapping("/{preapprovalId}/payment-history")
    public ResponseEntity<?> getPaymentHistory(
            @PathVariable String preapprovalId, Principal principal, HttpServletRequest request) {

        String userEmail = principal.getName();
        log.info(
                "Obteniendo historial de pagos para suscripción {} del usuario: {}",
                preapprovalId,
                userEmail);

        try {
            List<PaymentHistoryResponseDTO> response =
                    mercadoPagoPaymentService.getPaymentHistory(preapprovalId, userEmail);

            return new ResponseEntity<>(
                    ApiResponse.ok(
                            "Historial de pagos obtenido exitosamente",
                            response,
                            request.getRequestURI()),
                    HttpStatus.OK);

        } catch (Exception e) {
            log.error(
                    "Error al obtener historial de pagos para suscripción {} del usuario {}: {}",
                    preapprovalId,
                    userEmail,
                    e.getMessage(),
                    e);
            throw e; // Re-lanzar para que sea manejado por el GlobalExceptionHandler
        }
    }

    /**
     * Obtiene todas las suscripciones del usuario autenticado
     *
     * <p>Información del usuario autenticado
     *
     * @param request Información de la petición HTTP
     * @return Respuesta con las suscripciones del usuario
     */
    @GetMapping()
    public ResponseEntity<?> getMySubscriptions(HttpServletRequest request) {
        // método en el service para obtener la subscripción del usuarío
        SubscriptionResponseDTO response = mercadoPagoService.getUserSubscriptions();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Suscripciones obtenidas exitosamente", response, request.getRequestURI()),
                HttpStatus.OK);
    }

    // ================================
    // WEBHOOKS DE MERCADOPAGO
    // ================================

    /**
     * Webhook para notificaciones de preapproval de MercadoPago Maneja eventos como: authorized,
     * pending, cancelled, rejected
     *
     * <p>URL del webhook: POST /v1/subscription/webhook/preapproval
     *
     * @param notification Datos de la notificación enviada por MercadoPago
     * @param headers Headers de la petición HTTP
     * @return Respuesta confirmando la recepción del webhook
     */
    @PostMapping("/webhook/preapproval")
    public ResponseEntity<String> handlePreapprovalWebhook(
            @RequestBody Map<String, Object> notification,
            @RequestHeader Map<String, String> headers) {

        try {
            log.info("Webhook de preapproval recibido: {}", notification);
            log.debug("Headers del webhook: {}", headers);

            // Validar que es una notificación legítima de MercadoPago
            String action = (String) notification.get("action");
            String type = (String) notification.get("type");

            if ("payment.updated".equals(action)
                    || "subscription".equals(type)
                    || "preapproval".equals(type)
                    || action != null && action.contains("preapproval")) {

                // Extraer el ID del preapproval
                Map<String, Object> data = (Map<String, Object>) notification.get("data");
                if (data != null) {
                    String preapprovalId = (String) data.get("id");

                    if (preapprovalId != null) {
                        log.info(
                                "Procesando webhook para preapproval ID: {}, action: {}",
                                preapprovalId,
                                action);

                        // Validar webhook con respuesta apropiada
                        if (mercadoPagoWebhookService.isValidWebhook(notification, headers)) {
                            // Procesar el webhook de manera asíncrona para responder rápido a
                            // MercadoPago
                            mercadoPagoWebhookService.processPreapprovalWebhook(
                                    preapprovalId, action, notification);
                        } else {
                            log.warn("Webhook inválido rechazado: preapprovalId={}", preapprovalId);
                            // Retornar 401 para webhooks inválidos para que MercadoPago no los
                            // reenvíe
                            return ResponseEntity.status(401).body("UNAUTHORIZED");
                        }

                        return ResponseEntity.ok("OK");
                    }
                }
            }

            log.warn("Webhook no reconocido: action={}, type={}", action, type);
            return ResponseEntity.ok("IGNORED");

        } catch (Exception e) {
            log.error("Error procesando webhook de preapproval: {}", e.getMessage(), e);
            // MercadoPago requiere que respondamos con status 200 incluso si hay error
            // para evitar reenvíos innecesarios
            return ResponseEntity.ok("ERROR");
        }
    }

    /**
     * Webhook para notificaciones de pagos individuales de MercadoPago Maneja eventos como:
     * payment.created, payment.updated
     *
     * <p>URL del webhook: POST /v1/subscription/webhook/payment
     *
     * @param notification Datos de la notificación enviada por MercadoPago
     * @param headers Headers de la petición HTTP
     * @return Respuesta confirmando la recepción del webhook
     */
    @PostMapping("/webhook/payment")
    public ResponseEntity<String> handlePaymentWebhook(
            @RequestBody Map<String, Object> notification,
            @RequestHeader Map<String, String> headers) {

        try {
            log.info("Webhook de payment recibido: {}", notification);
            log.debug("Headers del webhook al momento de realizar el pago: {}", headers);

            String action = (String) notification.get("action");
            String type = (String) notification.get("type");

            if ("payment.created".equals(action)
                    || "payment.updated".equals(action)
                    || "payment".equals(type)) {

                Map<String, Object> data = (Map<String, Object>) notification.get("data");
                if (data != null) {
                    String paymentId = (String) data.get("id");

                    if (paymentId != null) {
                        log.info(
                                "Procesando webhook para payment ID: {}, action: {}",
                                paymentId,
                                action);

                        // Validar y procesar webhook de pago
                        if (mercadoPagoWebhookService.isValidWebhook(notification, headers)) {
                            mercadoPagoWebhookService.processPaymentWebhook(
                                    paymentId, action, notification);
                        } else {
                            log.warn("Webhook de pago inválido rechazado: paymentId={}", paymentId);
                            return ResponseEntity.ok("INVALID");
                        }

                        return ResponseEntity.ok("OK");
                    }
                }
            }

            log.warn("Webhook de payment no reconocido: action={}, type={}", action, type);
            return ResponseEntity.ok("IGNORED");

        } catch (Exception e) {
            log.error("Error procesando webhook de payment: {}", e.getMessage(), e);
            return ResponseEntity.ok("ERROR");
        }
    }

    /**
     * Webhook genérico para otras notificaciones de MercadoPago
     *
     * <p>URL del webhook: POST /v1/subscription/webhook/generic
     *
     * @param notification Datos de la notificación enviada por MercadoPago
     * @param headers Headers de la petición HTTP
     * @return Respuesta confirmando la recepción del webhook
     */
    @PostMapping("/webhook/generic")
    public ResponseEntity<String> handleGenericWebhook(
            @RequestBody Map<String, Object> notification,
            @RequestHeader Map<String, String> headers) {

        try {
            log.info("Webhook genérico recibido: {}", notification);
            log.debug("Headers del webhook al hacer una petición generica: {}", headers);

            String action = (String) notification.get("action");
            String type = (String) notification.get("type");

            log.info("Procesando webhook genérico: action={}, type={}", action, type);

            // Procesar webhook genérico
            if (mercadoPagoWebhookService.isValidWebhook(notification, headers)) {
                mercadoPagoWebhookService.processGenericWebhook(notification);
            } else {
                log.warn("Webhook genérico inválido rechazado");
                return ResponseEntity.ok("INVALID");
            }

            return ResponseEntity.ok("OK");

        } catch (Exception e) {
            log.error("Error procesando webhook genérico: {}", e.getMessage(), e);
            return ResponseEntity.ok("ERROR");
        }
    }
}
