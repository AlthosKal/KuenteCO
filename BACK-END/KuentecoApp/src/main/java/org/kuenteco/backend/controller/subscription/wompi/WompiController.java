package org.kuenteco.backend.controller.subscription.wompi;

import com.fasterxml.jackson.core.JsonProcessingException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.subscription.wompi.request.api.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.wompi.request.api.TokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.api.PaymentTokenResponseDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.api.SubscriptionPaymentResponseDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.subscription.wompi.PaymentTokenService;
import org.kuenteco.backend.service.subscription.wompi.SubscriptionPaymentService;
import org.kuenteco.backend.service.subscription.wompi.WompiWebhookService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/v1/wompi/payments")
@RequiredArgsConstructor
public class WompiController {

    private final PaymentTokenService paymentTokenService;
    private final SubscriptionPaymentService subscriptionPaymentService;
    private final WompiWebhookService webhookService;

    @PostMapping("/tokenize-card")
    public ResponseEntity<?> tokenizeCard(
            @Valid @RequestBody TokenizeCardRequestDTO dto, HttpServletRequest request) {
        PaymentTokenResponseDTO response = paymentTokenService.tokenizeAndSaveCard(dto);

        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Tarjeta tokenizada exitosamente", response, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/tokens")
    public ResponseEntity<?> getUserTokens(HttpServletRequest request) {
        List<PaymentTokenResponseDTO> tokens = paymentTokenService.getUserActiveTokens();

        return new ResponseEntity<>(
                ApiResponse.ok("Tokens obtenidos exitosamente", tokens, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/subscription")
    public ResponseEntity<?> createSubscriptionPayment(
            @Valid @RequestBody CreateSubscriptionRequestDTO dto, HttpServletRequest request)
            throws NoSuchAlgorithmException {
        SubscriptionPaymentResponseDTO response =
                subscriptionPaymentService.createSubscriptionPayment(dto);

        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Pago de suscripción procesado exitosamente",
                        response,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/subscription/{subscriptionId}")
    public ResponseEntity<?> getSubscriptionStatus(
            @PathVariable Integer subscriptionId, HttpServletRequest httpRequest) {
        SubscriptionPaymentResponseDTO response =
                subscriptionPaymentService.getSubscriptionStatus(subscriptionId);

        return ResponseEntity.ok(
                ApiResponse.ok(
                        "Estado de suscripción obtenido exitosamente",
                        response,
                        httpRequest.getRequestURI()));
    }

    @PostMapping("/webhook")
    public ResponseEntity<?> handleWompiWebhook(
            @RequestBody String payload,
            @RequestHeader(value = "X-Wompi-Signature", required = false) String signature)
            throws NoSuchAlgorithmException, InvalidKeyException, JsonProcessingException {
        log.info("Webhook recibido de Wompi");
        webhookService.processWebhook(payload, signature);
        return ResponseEntity.ok().build();
    }
}
