package org.kuenteco.backend.controller.subscription;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.security.Principal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.subscription.request.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.PaymentHistoryResponseDTO;
import org.kuenteco.backend.dto.subscription.response.SubscriptionResponseDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.subscription.MercadoPagoPaymentService;
import org.kuenteco.backend.service.subscription.MercadoPagoService;
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

    /**
     * Crea una nueva suscripción en Mercado Pago
     *
     * @param dto DTO con los datos de la suscripción a crear
     * @param principal Información del usuario autenticado
     * @param request Información de la petición HTTP
     * @return Respuesta con los datos de la suscripción creada
     */
    @PostMapping()
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
    @GetMapping("/my-subscriptions")
    public ResponseEntity<?> getMySubscriptions(HttpServletRequest request) {
        // método en el service para obtener la subscripción del usuarío
        SubscriptionResponseDTO response = mercadoPagoService.getUserSubscriptions();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Suscripciones obtenidas exitosamente", response, request.getRequestURI()),
                HttpStatus.OK);
    }
}
