package org.kuenteco.backend.service.logic.transaction.bancolombia;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeoutException;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.TokenResponseDTO;
import org.kuenteco.backend.entity.BancolombiaToken;
import org.kuenteco.backend.exception.exceptions.BancolombiaApiException;
import org.kuenteco.backend.exception.exceptions.BancolombiaAuthenticationException;
import org.kuenteco.backend.exception.exceptions.BancolombiaAuthorizationException;
import org.kuenteco.backend.exception.exceptions.BancolombiaException;
import org.kuenteco.backend.exception.exceptions.BancolombiaRateLimitException;
import org.kuenteco.backend.exception.exceptions.BancolombiaTimeoutException;
import org.kuenteco.backend.repository.master.MasterBancolombiaTokenRepository;
import org.kuenteco.backend.repository.slave.SlaveBancolombiaTokenRepository;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
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
        log.info("Solicitando nuevo token a Bancolombia");

        // Desactivar viejos
        slaveRepo
                .findAllByIsActiveTrue()
                .forEach(
                        t -> {
                            t.setIsActive(false);
                            masterRepo.save(t);
                        });

        // Payload JSON
        Map<String, String> body =
                Map.of(
                        "grant_type",
                        "client_credentials",
                        "scope",
                        props.getSandbox().getAuth().getScope());

        // Construir Basic Auth header
        String creds =
                props.getSandbox().getAuth().getClientId()
                        + ":"
                        + props.getSandbox().getAuth().getClientSecret();
        String basicAuth = "Basic " + Base64.getEncoder().encodeToString(creds.getBytes());

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
                                                    .path("/token")
                                                    .build())
                            .header("Authorization", basicAuth)
                            .contentType(MediaType.APPLICATION_JSON)
                            .bodyValue(body)
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
                            .onErrorMap(
                                    TimeoutException.class,
                                    ex ->
                                            new BancolombiaTimeoutException(
                                                    "Timeout solicitando token", ex))
                            .onErrorMap(
                                    WebClientResponseException.Unauthorized.class,
                                    ex ->
                                            new BancolombiaAuthenticationException(
                                                    "Credenciales inválidas", ex))
                            .onErrorMap(
                                    WebClientResponseException.Forbidden.class,
                                    ex ->
                                            new BancolombiaAuthorizationException(
                                                    "Acceso denegado", ex))
                            .onErrorMap(
                                    WebClientResponseException.TooManyRequests.class,
                                    ex ->
                                            new BancolombiaRateLimitException(
                                                    "Rate limit excedido", ex))
                            .onErrorMap(
                                    WebClientResponseException.class,
                                    ex ->
                                            new BancolombiaApiException(
                                                    "Error API Bancolombia: " + ex.getMessage(),
                                                    ex.getStatusCode().value(),
                                                    ex))
                            .block();
        } catch (Exception e) {
            throw (e instanceof BancolombiaException)
                    ? (BancolombiaException) e
                    : new BancolombiaApiException("Error inesperado al solicitar token", 500, e);
        }

        if (tr == null || tr.getAccessToken() == null) {
            throw new BancolombiaApiException("Respuesta inválida al obtener token", 500);
        }

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

        log.info("Token guardado y activo hasta {}", token.getExpiresAt());
        return token.getAccessToken();
    }

    @Override
    public void invalidateToken() {
        slaveRepo
                .findAllByIsActiveTrue()
                .forEach(
                        t -> {
                            t.setIsActive(false);
                            masterRepo.save(t);
                        });
    }

    @Override
    public void cleanupExpiredTokens() {
        LocalDateTime now = LocalDateTime.now();

        // 1) Desactivar tokens expirados
        List<BancolombiaToken> expirados = masterRepo.findAllByIsActiveTrueAndExpiresAtBefore(now);
        expirados.forEach(t -> t.setIsActive(false));
        masterRepo.saveAll(expirados);

        // 2) Borrar los muy antiguos (p. ej. > 7 días)
        LocalDateTime cutoff = now.minusDays(7);
        List<BancolombiaToken> antiquos = masterRepo.findAllByCreatedAtBefore(cutoff);
        masterRepo.deleteAll(antiquos);

        log.info(
                "Tokens expirados desactivados: {}, eliminados: {}",
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
