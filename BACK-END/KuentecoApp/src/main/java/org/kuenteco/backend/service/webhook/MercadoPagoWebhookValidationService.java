package org.kuenteco.backend.service.webhook;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class MercadoPagoWebhookValidationService {

    @Value("${mercadopago.webhooks.secret}")
    private String webhookSecret;

    @Value("${mercadopago.webhooks.skip-validation:false}")
    private boolean skipValidation;

    /**
     * Valida la autenticidad del webhook usando la firma x-signature de MercadoPago
     *
     * @param headers Headers HTTP de la petición
     * @param dataId ID del evento desde query params o body
     * @param requestBody Cuerpo completo de la petición como String
     * @return true si el webhook es auténtico, false si no
     */
    public boolean isValidWebhookSignature(
            Map<String, String> headers, String dataId, String requestBody) {
        // Para testing: permitir saltar validaciones
        if (skipValidation) {
            log.info("Validación de webhook saltada (modo testing)");
            return true;
        }

        try {
            // Obtener headers necesarios
            String xSignature = headers.get("x-signature");
            String xRequestId = headers.get("x-request-id");

            if (xSignature == null || xRequestId == null) {
                log.warn(
                        "Headers requeridos faltantes: x-signature={}, x-request-id={}",
                        xSignature,
                        xRequestId);
                return false;
            }

            // Extraer timestamp y firma del header x-signature
            String[] parts = xSignature.split(",");
            String ts = null;
            String v1 = null;

            for (String part : parts) {
                String[] keyValue = part.split("=", 2);
                if (keyValue.length == 2) {
                    String key = keyValue[0].trim();
                    String value = keyValue[1].trim();

                    if ("ts".equals(key)) {
                        ts = value;
                    } else if ("v1".equals(key)) {
                        v1 = value;
                    }
                }
            }

            if (ts == null || v1 == null) {
                log.warn("No se pudieron extraer ts y v1 del header x-signature: {}", xSignature);
                return false;
            }

            // Validar timestamp (no más de 15 minutos de diferencia)
            long timestampMs = Long.parseLong(ts) * 1000; // ts está en segundos
            long currentTime = System.currentTimeMillis();
            long timeDifferenceMs = Math.abs(currentTime - timestampMs);

            if (timeDifferenceMs > 15 * 60 * 1000) { // 15 minutos
                log.warn(
                        "Webhook timestamp muy antiguo o futuro. Diferencia: {} ms",
                        timeDifferenceMs);
                return false;
            }

            // Crear el template de manifest según documentación de MercadoPago:
            // id:[data.id_url];request-id:[x-request-id_header];ts:[ts_header];
            String manifest =
                    String.format(
                            "id:%s;request-id:%s;ts:%s;",
                            dataId != null ? dataId.toLowerCase() : "",
                            xRequestId != null ? xRequestId : "",
                            ts);

            log.debug("Manifest generado: {}", manifest);

            // Generar la firma HMAC SHA256
            String expectedSignature = generateHmacSha256(manifest, webhookSecret);

            // Comparar firmas
            boolean isValid = expectedSignature.equals(v1);

            if (!isValid) {
                log.warn(
                        "Firma de webhook inválida. Esperada: {}, Recibida: {}",
                        expectedSignature,
                        v1);
                log.debug("Manifest usado: {}", manifest);
            } else {
                log.info("Webhook validado exitosamente");
            }

            return isValid;

        } catch (Exception e) {
            log.error("Error validando webhook: {}", e.getMessage(), e);
            return false;
        }
    }

    /** Genera HMAC SHA256 de un mensaje con una clave secreta */
    private String generateHmacSha256(String message, String secret)
            throws NoSuchAlgorithmException, InvalidKeyException {

        Mac sha256Hmac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKey =
                new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        sha256Hmac.init(secretKey);

        byte[] hash = sha256Hmac.doFinal(message.getBytes(StandardCharsets.UTF_8));

        // Convertir a hexadecimal
        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }

        return hexString.toString();
    }

    /** Extrae el data.id desde los query parameters o el body del webhook */
    public String extractDataId(Map<String, Object> notification, String queryParams) {
        try {
            // Primero intentar desde query params si están disponibles
            if (queryParams != null && queryParams.contains("data.id=")) {
                String[] params = queryParams.split("&");
                for (String param : params) {
                    if (param.startsWith("data.id=")) {
                        return param.substring("data.id=".length());
                    }
                }
            }

            // Luego intentar desde el body
            if (notification != null) {
                Map<String, Object> data = (Map<String, Object>) notification.get("data");
                if (data != null && data.get("id") != null) {
                    return String.valueOf(data.get("id"));
                }
            }

            return null;

        } catch (Exception e) {
            log.error("Error extrayendo data.id: {}", e.getMessage(), e);
            return null;
        }
    }
}
