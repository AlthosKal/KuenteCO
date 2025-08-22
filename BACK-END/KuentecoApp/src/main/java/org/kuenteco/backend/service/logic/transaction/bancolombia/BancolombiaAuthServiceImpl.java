package org.kuenteco.backend.service.logic.transaction.bancolombia;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.TimeoutException;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.TokenResponseDTO;
import org.kuenteco.backend.entity.BancolombiaToken;
import org.kuenteco.backend.exception.exceptions.*;
import org.kuenteco.backend.repository.master.MasterBancolombiaTokenRepository;
import org.kuenteco.backend.repository.slave.SlaveBancolombiaTokenRepository;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.util.retry.Retry;

@Service
@Slf4j
public class BancolombiaAuthServiceImpl implements BancolombiaAuthService {

    private final WebClient authWebClient;
    private final BancolombiaProperties props;
    private final MasterBancolombiaTokenRepository masterRepo;
    private final SlaveBancolombiaTokenRepository slaveRepo;

    public BancolombiaAuthServiceImpl(
            @Qualifier("authWebClient") WebClient authWebClient,
            BancolombiaProperties props,
            MasterBancolombiaTokenRepository masterRepo,
            SlaveBancolombiaTokenRepository slaveRepo) {
        this.authWebClient = authWebClient;
        this.props = props;
        this.masterRepo = masterRepo;
        this.slaveRepo = slaveRepo;
    }

    @Override
    public String getValidToken() {
        LocalDateTime now = LocalDateTime.now();
        return slaveRepo
                .findFirstByIsActiveTrueAndExpiresAtAfterOrderByCreatedAtDesc(now)
                .filter(
                        token ->
                                !token.isExpiredWithBuffer(
                                        props.getSandbox()
                                                .getAuth()
                                                .getTokenExpirationBufferSeconds()))
                .map(BancolombiaToken::getAccessToken)
                .orElseGet(this::requestNewToken);
    }

    @Override
    public String requestNewToken() {
        log.info("🔄 Solicitando nuevo token a Bancolombia");

        // Desactivar tokens anteriores
        slaveRepo
                .findAllByIsActiveTrue()
                .forEach(
                        t -> {
                            t.setIsActive(false);
                            masterRepo.save(t);
                        });

        // ✅ Usar Bearer Auth como en el curl
        String bearerAuth = "Bearer " + props.getSandbox().getAuth().getClientSecret();

        // ✅ Debug info
        log.debug("🔍 Token request details:");
        log.debug(
                "  - URL: {}{}",
                authWebClient.toString(),
                props.getSandbox().getAuth().getTokenUrlBasePath());
        log.debug("  - Client ID: {}", props.getSandbox().getAuth().getClientId());
        log.debug("  - Auth: Bearer [HIDDEN]");

        TokenResponseDTO tr;
        try {
            tr =
                    authWebClient
                            .post()
                            .uri(
                                    uriBuilder ->
                                            uriBuilder
                                                    .path(
                                                            props.getSandbox()
                                                                    .getAuth()
                                                                    .getTokenUrlBasePath())
                                                    .build())
                            // ✅ Bearer Auth exacto como en el curl
                            .header("Authorization", bearerAuth)
                            // ✅ Content-Type ya está configurado en WebClient
                            .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                            // ✅ Solo grant_type como en el curl - SIN scope
                            .body(BodyInserters.fromFormData("grant_type", "client_credentials"))
                            .retrieve()
                            .bodyToMono(TokenResponseDTO.class)
                            .retryWhen(
                                    Retry.backoff(
                                                    props.getSandbox().getApi().getMaxRetries(),
                                                    Duration.ofSeconds(1))
                                            .filter(
                                                    ex ->
                                                            !(ex
                                                                    instanceof
                                                                    WebClientResponseException
                                                                            .Unauthorized)))
                            .timeout(
                                    Duration.ofSeconds(
                                            props.getSandbox().getApi().getTimeoutSeconds()))
                            // ✅ Manejo mejorado de errores con logging
                            .onErrorMap(
                                    TimeoutException.class,
                                    ex -> {
                                        log.error(
                                                "⏱️ Timeout solicitando token después de {}s",
                                                props.getSandbox().getApi().getTimeoutSeconds());
                                        return new BancolombiaTimeoutException(
                                                "Timeout solicitando token", ex);
                                    })
                            .onErrorMap(
                                    WebClientResponseException.Unauthorized.class,
                                    ex -> {
                                        log.error(
                                                "🔐 Error 401: Credenciales inválidas - Response: {}",
                                                ex.getResponseBodyAsString());
                                        return new BancolombiaAuthenticationException(
                                                "Credenciales inválidas", ex);
                                    })
                            .onErrorMap(
                                    WebClientResponseException.Forbidden.class,
                                    ex -> {
                                        log.error(
                                                "🚫 Error 403: Acceso denegado - Response: {}",
                                                ex.getResponseBodyAsString());
                                        return new BancolombiaAuthorizationException(
                                                "Acceso denegado", ex);
                                    })
                            .onErrorMap(
                                    WebClientResponseException.TooManyRequests.class,
                                    ex -> {
                                        log.error(
                                                "🚦 Error 429: Rate limit excedido - Response: {}",
                                                ex.getResponseBodyAsString());
                                        return new BancolombiaRateLimitException(
                                                "Rate limit excedido", ex);
                                    })
                            .onErrorMap(
                                    WebClientResponseException.class,
                                    ex -> {
                                        log.error(
                                                "❌ Error HTTP {}: {} - Response: {}",
                                                ex.getStatusCode(),
                                                ex.getMessage(),
                                                ex.getResponseBodyAsString());
                                        return new BancolombiaApiException(
                                                "Error API Bancolombia: " + ex.getMessage(),
                                                ex.getStatusCode().value(),
                                                ex);
                                    })
                            .block();

        } catch (Exception e) {
            log.error("❌ Error inesperado solicitando token: {}", e.getMessage(), e);
            throw (e instanceof BancolombiaException)
                    ? (BancolombiaException) e
                    : new BancolombiaApiException("Error inesperado al solicitar token", 500, e);
        }

        if (tr == null || tr.getAccessToken() == null) {
            log.error("❌ Respuesta de token nula o inválida");
            throw new BancolombiaApiException("Respuesta inválida al obtener token", 500);
        }

        // ✅ Log del token obtenido (primeros caracteres para debugging)
        log.debug(
                "✅ Token obtenido - Tipo: {}, Expires in: {}s, Scope: {}",
                tr.getTokenType(),
                tr.getExpiresIn(),
                tr.getScope());
        log.debug(
                "✅ Token (primeros 20 chars): {}",
                tr.getAccessToken().substring(0, Math.min(20, tr.getAccessToken().length())));

        // Guardar en BD
        BancolombiaToken token =
                BancolombiaToken.builder()
                        .accessToken(tr.getAccessToken())
                        .tokenType(tr.getTokenType())
                        .expiresIn(tr.getExpiresIn())
                        .scope(tr.getScope())
                        .refreshToken(tr.getRefreshToken())
                        .isActive(true)
                        .build();

        masterRepo.save(token);
        log.info("✅ Token guardado y activo hasta {}", token.getExpiresAt());
        return token.getAccessToken();
    }

    @Override
    public void invalidateToken() {
        List<BancolombiaToken> activeTokens = slaveRepo.findAllByIsActiveTrue();
        activeTokens.forEach(
                t -> {
                    t.setIsActive(false);
                    masterRepo.save(t);
                });
        log.debug("🗑️ Tokens invalidados: {}", activeTokens.size());
    }

    @Override
    public void cleanupExpiredTokens() {
        LocalDateTime now = LocalDateTime.now();

        // Desactivar tokens expirados
        List<BancolombiaToken> expirados = masterRepo.findAllByIsActiveTrueAndExpiresAtBefore(now);
        expirados.forEach(t -> t.setIsActive(false));
        masterRepo.saveAll(expirados);

        // Borrar tokens antiguos (> 7 días)
        LocalDateTime cutoff = now.minusDays(7);
        List<BancolombiaToken> antiquos = masterRepo.findAllByCreatedAtBefore(cutoff);
        masterRepo.deleteAll(antiquos);

        log.info(
                "🧹 Limpieza completada - Tokens expirados desactivados: {}, eliminados: {}",
                expirados.size(),
                antiquos.size());
    }

    @Override
    public boolean hasValidToken() {
        LocalDateTime now = LocalDateTime.now();
        return slaveRepo
                .findFirstByIsActiveTrueAndExpiresAtAfterOrderByCreatedAtDesc(now)
                .isPresent();
    }

    @Override
    public BancolombiaToken getCurrentToken() {
        LocalDateTime now = LocalDateTime.now();
        return slaveRepo
                .findFirstByIsActiveTrueAndExpiresAtAfterOrderByCreatedAtDesc(now)
                .orElse(null);
    }
}
