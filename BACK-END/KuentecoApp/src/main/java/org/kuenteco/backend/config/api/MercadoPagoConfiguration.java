package org.kuenteco.backend.config.api;

import com.mercadopago.MercadoPagoConfig;
import jakarta.annotation.PostConstruct;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Slf4j
@Setter
@Configuration
public class MercadoPagoConfiguration {

    @Value("${mercadopago.access-token}")
    private String accessToken;

    @Value("${mercadopago.environment:sandbox}")
    private String environment;

    @PostConstruct
    public void init() {
        try {
            MercadoPagoConfig.setAccessToken(accessToken);

            // En el SDK v2.5.0, el entorno se determina automáticamente por el access token:
            // - TEST-* tokens usan sandbox
            // - APP_USR-* tokens usan production

            if (accessToken != null) {
                if (accessToken.startsWith("TEST-")) {
                    log.info("MercadoPago configurado en modo SANDBOX (token TEST detectado)");
                } else if (accessToken.startsWith("APP_USR-")) {
                    log.info(
                            "MercadoPago configurado en modo PRODUCCIÓN (token APP_USR detectado)");
                } else {
                    log.warn(
                            "Token de MercadoPago no reconocido. Formato esperado: TEST-* o APP_USR-*");
                }
            }

            log.info("MercadoPago configurado correctamente con entorno: {}", environment);
        } catch (Exception e) {
            log.error("Error al configurar MercadoPago", e);
            throw new IllegalArgumentException("Error al configurar MercadoPago", e);
        }
    }
}
