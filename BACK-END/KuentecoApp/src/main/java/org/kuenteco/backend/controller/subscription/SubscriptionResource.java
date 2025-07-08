package org.kuenteco.backend.controller.subscription;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.security.Principal;
import org.kuenteco.backend.dto.subscription.request.CreateSubscriptionRequestDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/** Interfaz que define los endpoints para la integración con Mercado Pago */
public interface SubscriptionResource {

    /** Crea una nueva suscripción en Mercado Pago */
    @PostMapping("/subscription")
    ResponseEntity<?> createSubscription(
            @Valid @RequestBody CreateSubscriptionRequestDTO dto,
            Principal principal,
            HttpServletRequest request);

    /** Obtiene los detalles de una suscripción específica */
    @GetMapping("/subscription/{preapprovalId}")
    ResponseEntity<?> getSubscription(
            @PathVariable String preapprovalId, Principal principal, HttpServletRequest request);

    /** Obtiene el historial de pagos de una suscripción específica */
    @GetMapping("/subscription/{preapprovalId}/payment-history")
    ResponseEntity<?> getPaymentHistory(
            @PathVariable String preapprovalId, Principal principal, HttpServletRequest request);
}
