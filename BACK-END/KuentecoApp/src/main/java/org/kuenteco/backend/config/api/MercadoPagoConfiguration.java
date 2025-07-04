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

    @PostConstruct
    public void init() {
        try {
            MercadoPagoConfig.setAccessToken(accessToken);
            log.info("MercadoPago configurado correctamente");
        } catch (Exception e) {
            log.error("Error al configurar MercadoPago", e);
            throw new RuntimeException("Error al configurar MercadoPago", e);
        }
    }
}
