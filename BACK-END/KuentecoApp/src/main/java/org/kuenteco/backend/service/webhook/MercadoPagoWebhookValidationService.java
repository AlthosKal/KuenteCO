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
            // Validar headers requeridos
            WebhookHeaders webhookHeaders = extractAndValidateHeaders(headers);
            if (webhookHeaders == null) {
                return false;
            }

            // Extraer timestamp y firma
            SignatureComponents signatureComponents =
                    parseSignatureHeader(webhookHeaders.xSignature());
            if (signatureComponents == null) {
                return false;
            }

            // Validar timestamp
            if (!isValidTimestamp(signatureComponents.timestamp())) {
                return false;
            }

            // Generar y validar firma
            return validateSignature(
                    webhookHeaders.xRequestId(),
                    dataId,
                    signatureComponents.timestamp(),
                    signatureComponents.signature());

        } catch (Exception e) {
            log.error("Error validando webhook: {}", e.getMessage(), e);
            return false;
        }
    }

    /** Extrae y valida los headers necesarios del webhook */
    private WebhookHeaders extractAndValidateHeaders(Map<String, String> headers) {
        String xSignature = headers.get("x-signature");
        String xRequestId = headers.get("x-request-id");

        if (xSignature == null || xRequestId == null) {
            log.warn(
                    "Headers requeridos faltantes: x-signature={}, x-request-id={}",
                    xSignature,
                    xRequestId);
            return null;
        }

        return new WebhookHeaders(xSignature, xRequestId);
    }

    /** Parsea el header x-signature para extraer timestamp y firma */
    private SignatureComponents parseSignatureHeader(String xSignature) {
        String[] parts = xSignature.split(",");
        String ts = null;
        String v1 = null;

        for (String part : parts) {
            SignatureKeyValue keyValue = parseSignaturePart(part);
            if (keyValue != null) {
                if ("ts".equals(keyValue.key())) {
                    ts = keyValue.value();
                } else if ("v1".equals(keyValue.key())) {
                    v1 = keyValue.value();
                }
            }
        }

        if (ts == null || v1 == null) {
            log.warn("No se pudieron extraer ts y v1 del header x-signature: {}", xSignature);
            return null;
        }

        return new SignatureComponents(ts, v1);
    }

    /** Parsea una parte individual del header de firma */
    private SignatureKeyValue parseSignaturePart(String part) {
        String[] keyValue = part.split("=", 2);
        if (keyValue.length != 2) {
            return null;
        }

        String key = keyValue[0].trim();
        String value = keyValue[1].trim();

        return new SignatureKeyValue(key, value);
    }

    /** Valida que el timestamp no sea muy antiguo o futuro */
    private boolean isValidTimestamp(String timestampStr) {
        try {
            long timestampMs = Long.parseLong(timestampStr) * 1000; // ts está en segundos
            long currentTime = System.currentTimeMillis();
            long timeDifferenceMs = Math.abs(currentTime - timestampMs);

            boolean isValid = timeDifferenceMs <= 15 * 60 * 1000; // 15 minutos

            if (!isValid) {
                log.warn(
                        "Webhook timestamp muy antiguo o futuro. Diferencia: {} ms",
                        timeDifferenceMs);
            }

            return isValid;

        } catch (NumberFormatException e) {
            log.warn("Timestamp inválido: {}", timestampStr);
            return false;
        }
    }

    /** Valida la firma generando el manifest y comparando con la firma esperada */
    private boolean validateSignature(
            String xRequestId, String dataId, String timestamp, String receivedSignature) {
        try {
            // Crear el template de manifest según documentación de MercadoPago
            String manifest = buildManifest(dataId, xRequestId, timestamp);
            log.debug("Manifest generado: {}", manifest);

            // Generar la firma HMAC SHA256
            String expectedSignature = generateHmacSha256(manifest, webhookSecret);

            // Comparar firmas
            boolean isValid = expectedSignature.equals(receivedSignature);

            if (!isValid) {
                log.warn(
                        "Firma de webhook inválida. Esperada: {}, Recibida: {}",
                        expectedSignature,
                        receivedSignature);
                log.debug("Manifest usado: {}", manifest);
            } else {
                log.info("Webhook validado exitosamente");
            }

            return isValid;

        } catch (Exception e) {
            log.error("Error generando o comparando firma: {}", e.getMessage(), e);
            return false;
        }
    }

    /** Construye el manifest según la especificación de MercadoPago */
    private String buildManifest(String dataId, String xRequestId, String timestamp) {
        return String.format(
                "id:%s;request-id:%s;ts:%s;",
                dataId != null ? dataId.toLowerCase() : "",
                xRequestId != null ? xRequestId : "",
                timestamp);
    }

    // Records para encapsular datos relacionados
    private record WebhookHeaders(String xSignature, String xRequestId) {}

    private record SignatureComponents(String timestamp, String signature) {}

    private record SignatureKeyValue(String key, String value) {}

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
