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
    private static final String ACTION = "action";
    private static final String TYPE = "type";
    private static final String DATA = "data";

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

    @PostMapping("/webhook")
    public ResponseEntity<String> handleWebhook(
            @RequestBody Map<String, Object> notification,
            @RequestHeader Map<String, String> headers) {
        try {
            log.info("Webhook unificado recibido: {}", notification);
            log.debug("Headers del webhook: {}", headers);

            String action = (String) notification.get(ACTION);
            String type = (String) notification.get(TYPE);
            Map<String, Object> data = (Map<String, Object>) notification.get(DATA);

            if (data == null || data.get("id") == null) {
                log.warn("Webhook sin datos o ID");
                return ResponseEntity.ok("IGNORED");
            }

            String id = (String) data.get("id");

            // Validar webhook
            if (!mercadoPagoWebhookService.isValidWebhook(notification, headers)) {
                log.warn("Webhook inválido rechazado: id={}", id);
                return ResponseEntity.status(401).body("UNAUTHORIZED");
            }

            // Determinar tipo de webhook y procesar
            if ("subscription_preapproval".equals(type)) {
                log.info("Procesando webhook de preapproval: ID={}, action={}", id, action);
                mercadoPagoWebhookService.processPreapprovalWebhook(id, action, notification);
            } else if ("subscription_authorized_payment".equals(type)) {
                log.info(
                        "Procesando webhook de subscription_authorized_payment: ID={}, action={}",
                        id,
                        action);
                mercadoPagoWebhookService.processSubscriptionAuthorizedPaymentWebhook(
                        id, action, notification);
            } else if ("payment".equals(type)) {
                log.info("Procesando webhook de payment: ID={}, action={}", id, action);
                mercadoPagoWebhookService.processPaymentWebhook(id, action, notification);
            } else {
                log.info("Procesando webhook genérico: action={}, type={}", action, type);
                mercadoPagoWebhookService.processGenericWebhook(notification);
            }

            return ResponseEntity.ok("OK");
        } catch (Exception e) {
            log.error("Error procesando webhook: {}", e.getMessage(), e);
            // MercadoPago requiere que respondamos con status 200 incluso si hay error
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /** Determina si la notificación corresponde a un preapproval */
    private boolean isPreapprovalNotification(String action, String type) {
        if ("subscription".equals(type) || "preapproval".equals(type)) {
            return true;
        }
        if (action != null) {
            return action.contains("preapproval")
                    || "authorized".equals(action)
                    || "pending".equals(action)
                    || "cancelled".equals(action)
                    || "rejected".equals(action)
                    || "paused".equals(action);
        }
        return false;
    }

    /** Determina si la notificación corresponde a un payment */
    private boolean isPaymentNotification(String action, String type) {
        if ("payment".equals(type)) {
            return true;
        }
        if (action != null) {
            return action.startsWith("payment.");
        }
        return false;
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
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
