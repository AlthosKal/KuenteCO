package org.kuenteco.backend.job;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.service.logic.transaction.bancolombia.BancolombiaAuthService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class TokenMaintenanceJob {

    private final BancolombiaAuthService authService;

    /** Limpia tokens expirados cada noche a la 1 AM */
    @Scheduled(cron = "0 0 1 * * *") // Hora del servidor
    public void cleanUpTokens() {
        log.info("Ejecutando limpieza de tokens expirados");
        authService.cleanupExpiredTokens();
    }
}
