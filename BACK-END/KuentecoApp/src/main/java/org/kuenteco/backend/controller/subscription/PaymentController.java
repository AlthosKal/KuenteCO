package org.kuenteco.backend.controller.subscription;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.subscription.request.api.TokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.response.api.PaymentTokenResponseDTO;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.subscription.SubscriptionPaymentService;
import org.kuenteco.backend.service.wompi.PaymentTokenService;
import org.kuenteco.backend.service.wompi.WompiWebhookService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

@Slf4j
@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentTokenService paymentTokenService;
    private final SubscriptionPaymentService subscriptionPaymentService;
    private final WompiWebhookService webhookService;
    private final SlaveUserRepository slaveUserRepository;

    @PostMapping("/tokenize-card")
    public ResponseEntity<ApiResponse<PaymentTokenResponseDTO>> tokenizeCard(
            @Valid @RequestBody TokenizeCardRequestDTO request,
            HttpServletRequest httpRequest) {

        try {
            AuthCredentials credentials = getCredentials();
            String email = credentials.email();

            PaymentTokenResponseDTO response = paymentTokenService.tokenizeAndSaveCard(request);

            return ResponseEntity.ok(
                    ApiResponse.ok("Tarjeta tokenizada exitosamente", response, httpRequest.getRequestURI())
            );

        } catch (Exception e) {
            log.error("Error al tokenizar tarjeta: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Error al tokenizar tarjeta: " + e.getMessage(),
                            httpRequest.getRequestURI()));
        }
    }

    @GetMapping("/tokens")
    public ResponseEntity<ApiResponse<List<PaymentTokenResponse>>> getUserTokens(
            HttpServletRequest httpRequest) {

        try {
            AuthCredentials credentials = AuthUtils.getCredentials();
            User user = getUserByEmail(credentials.getEmail());

            List<PaymentTokenResponse> tokens = paymentTokenService.getUserActiveTokens(user);

            return ResponseEntity.ok(
                    ApiResponse.ok("Tokens obtenidos exitosamente", tokens, httpRequest.getRequestURI())
            );

        } catch (Exception e) {
            log.error("Error al obtener tokens: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Error al obtener tokens: " + e.getMessage(),
                            httpRequest.getRequestURI()));
        }
    }

    @PostMapping("/subscription")
    public ResponseEntity<ApiResponse<SubscriptionPaymentResponse>> createSubscriptionPayment(
            @Valid @RequestBody CreateSubscriptionRequest request,
            HttpServletRequest httpRequest) {

        try {
            AuthCredentials credentials = AuthUtils.getCredentials();
            User user = getUserByEmail(credentials.getEmail());

            SubscriptionPaymentResponse response = subscriptionPaymentService
                    .createSubscriptionPayment(user, request);

            return ResponseEntity.ok(
                    ApiResponse.ok("Pago de suscripción procesado exitosamente", response,
                            httpRequest.getRequestURI())
            );

        } catch (Exception e) {
            log.error("Error al procesar pago de suscripción: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Error al procesar pago: " + e.getMessage(),
                            httpRequest.getRequestURI()));
        }
    }

    @GetMapping("/subscription/{subscriptionId}")
    public ResponseEntity<ApiResponse<SubscriptionPaymentResponse>> getSubscriptionStatus(
            @PathVariable Integer subscriptionId,
            HttpServletRequest httpRequest) {

        try {
            AuthCredentials credentials = AuthUtils.getCredentials();
            User user = getUserByEmail(credentials.getEmail());

            SubscriptionPaymentResponse response = subscriptionPaymentService
                    .getSubscriptionStatus(subscriptionId, user);

            return ResponseEntity.ok(
                    ApiResponse.ok("Estado de suscripción obtenido exitosamente", response,
                            httpRequest.getRequestURI())
            );

        } catch (Exception e) {
            log.error("Error al obtener estado de suscripción: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Error al obtener estado: " + e.getMessage(),
                            httpRequest.getRequestURI()));
        }
    }

    @PostMapping("/webhook/wompi")
    public ResponseEntity<Void> handleWompiWebhook(
            @RequestBody String payload,
            @RequestHeader(value = "X-Wompi-Signature", required = false) String signature) {

        try {
            log.info("Webhook recibido de Wompi");
            webhookService.processWebhook(payload, signature);
            return ResponseEntity.ok().build();

        } catch (Exception e) {
            log.error("Error al procesar webhook: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    private User getUserByEmail(String email) {
        return slaveUserRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    }
}