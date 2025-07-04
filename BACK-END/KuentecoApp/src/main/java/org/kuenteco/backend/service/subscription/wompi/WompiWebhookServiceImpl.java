package org.kuenteco.backend.service.subscription.wompi;

import static org.kuenteco.backend.service.subscription.wompi.SubscriptionPaymentServiceImpl.mapWompiStatusToPaymentStatus;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
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

@Slf4j
@Service
@RequiredArgsConstructor
public class WompiWebhookServiceImpl implements WompiWebhookService {
    private final WompiConfig wompiConfig;
    private final ObjectMapper objectMapper;
    private final MasterPaySubscriptionRepository masterPaySubscriptionRepository;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final SlavePaySubscriptionRepository slavePaySubscriptionRepository;

    @Override
    public void processWebhook(String payload, String signature)
            throws NoSuchAlgorithmException, InvalidKeyException, JsonProcessingException {
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
    }

    private void processTransactionUpdate(JsonNode transactionData) {
        String transactionId = transactionData.get("id").asText();
        String status = transactionData.get("status").asText();

        log.info("Actualizando transacción {}: {}", transactionId, status);

        // Buscar el pago por transaction ID
        PaySubscription paySubscription =
                slavePaySubscriptionRepository.findByTransactionId(transactionId).orElse(null);

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

        log.info(
                "Estado de suscripción {} actualizado a {}",
                subscription.getId(),
                subscription.getState());
    }

    private boolean verifyWebhookSignature(String payload, String signature)
            throws NoSuchAlgorithmException, InvalidKeyException {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec =
                new SecretKeySpec(
                        wompiConfig.getEventsSecret().getBytes(StandardCharsets.UTF_8),
                        "HmacSHA256");
        mac.init(secretKeySpec);

        byte[] hash = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
        String expectedSignature = Base64.getEncoder().encodeToString(hash);

        return expectedSignature.equals(signature);
    }
}
