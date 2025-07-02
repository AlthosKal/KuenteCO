package org.kuenteco.backend.service.wompi;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.api.WompiConfig;
import org.kuenteco.backend.entity.PaySubscription;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.enums.PaymentStatus;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.repository.master.MasterPaySubscriptionRepository;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlavePaySubscriptionRepository;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Slf4j
@Service
@RequiredArgsConstructor
public class WompiWebhookServiceImpl implements  WompiWebhookService {
    private final WompiConfig wompiConfig;
    private final ObjectMapper objectMapper;
    private final MasterPaySubscriptionRepository masterPaySubscriptionRepository;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final SlavePaySubscriptionRepository slavePaySubscriptionRepository;

    @Override
    public void processWebhook(String payload, String signature) {
        try {
            // Verificar firma
            if (!verifyWebhookSignature(payload, signature)) {
                log.warn("Webhook con firma inválida recibido");
                return;
            }

            JsonNode webhookData = objectMapper.readTree(payload);
            String eventType = webhookData.get("event").asText();
            JsonNode data = webhookData.get("data");

            log.info("Procesando webhook de tipo: {}", eventType);

            if ("transaction.updated".equals(eventType)) {
                processTransactionUpdate(data);
            }

        } catch (Exception e) {
            log.error("Error al procesar webhook: {}", e.getMessage(), e);
        }
    }

    private void processTransactionUpdate(JsonNode transactionData) {
        try {
            String transactionId = transactionData.get("id").asText();
            String status = transactionData.get("status").asText();

            log.info("Actualizando transacción {}: {}", transactionId, status);

            // Buscar el pago por transaction ID
            PaySubscription paySubscription = slavePaySubscriptionRepository
                    .findByTransactionId(transactionId)
                    .orElse(null);

            if (paySubscription == null) {
                log.warn("No se encontró pago para transacción: {}", transactionId);
                return;
            }

            // Actualizar estado del pago
            PaymentStatus newStatus = mapWompiStatusToPaymentStatus(status);
            paySubscription.setStatus(newStatus);
            masterPaySubscriptionRepository.save(paySubscription);

            // Actualizar estado de suscripción
            Subscription subscription = paySubscription.getSubscription();
            if (newStatus == PaymentStatus.APPROVED) {
                subscription.setState(State.ACTIVE);
            } else if (newStatus == PaymentStatus.DECLINED || newStatus == PaymentStatus.ERROR) {
                subscription.setState(State.INACTIVE);
            }
            masterSubscriptionRepository.save(subscription);

            log.info("Estado de suscripción {} actualizado a {}",
                    subscription.getId(), subscription.getState());

        } catch (Exception e) {
            log.error("Error al procesar actualización de transacción: {}", e.getMessage(), e);
        }
    }

    private boolean verifyWebhookSignature(String payload, String signature) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKeySpec = new SecretKeySpec(
                    wompiConfig.getEventsSecret().getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(secretKeySpec);

            byte[] hash = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            String expectedSignature = Base64.getEncoder().encodeToString(hash);

            return expectedSignature.equals(signature);
        } catch (Exception e) {
            log.error("Error al verificar firma del webhook: {}", e.getMessage(), e);
            return false;
        }
    }

    private PaymentStatus mapWompiStatusToPaymentStatus(String wompiStatus) {
        return switch (wompiStatus.toUpperCase()) {
            case "APPROVED" -> PaymentStatus.APPROVED;
            case "DECLINED" -> PaymentStatus.DECLINED;
            case "VOIDED" -> PaymentStatus.VOIDED;
            case "ERROR" -> PaymentStatus.ERROR;
            default -> PaymentStatus.PENDING;
        };
    }
}
