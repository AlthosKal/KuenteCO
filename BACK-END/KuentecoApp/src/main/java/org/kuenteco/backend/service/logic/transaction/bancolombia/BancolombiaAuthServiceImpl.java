package org.kuenteco.backend.service.logic.transaction.bancolombia;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.TokenResponseDTO;
import org.kuenteco.backend.entity.BancolombiaToken;
import org.kuenteco.backend.exception.exceptions.*;
import org.kuenteco.backend.repository.master.MasterBancolombiaTokenRepository;
import org.kuenteco.backend.repository.slave.SlaveBancolombiaTokenRepository;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.TimeoutException;

@Service
@RequiredArgsConstructor
@Slf4j
public class BancolombiaAuthServiceImpl implements BancolombiaAuthService {
    private final WebClient bancolombiaWebClient;
    private final MasterBancolombiaTokenRepository masterBancolombiaTokenRepository;
    private final SlaveBancolombiaTokenRepository slaveBancolombiaTokenRepository;
    private final BancolombiaProperties bancolombiaProperties;

    /**
     * Obtiene un token válido. Si no existe o está expirado, solicita uno nuevo.
     */
    @Override
    public String getValidToken() {
        log.debug("Obteniendo token válido de Bancolombia");

        // Buscar token válido en base de datos findValidToken
        LocalDateTime currentTime = LocalDateTime.now();
        var validToken = slaveBancolombiaTokenRepository.findFirstByIsActiveTrueAndExpiresAtAfterOrderByCreatedAtDesc(currentTime);

        if (validToken.isPresent()) {
            var token = validToken.get();

            // Verificar si el token está cerca de expirar
            if (!token.isExpiredWithBuffer(bancolombiaProperties.getSandbox().getAuth().getTokenExpirationBufferSeconds())) {
                log.debug("Token válido encontrado en base de datos");
                return token.getAccessToken();
            } else {
                log.debug("Token próximo a expirar, solicitando nuevo token");
            }
        }

        // Si no hay token válido, solicitar uno nuevo
        return requestNewToken();
    }

    /**
     * Solicita un nuevo token de acceso a Bancolombia
     */
    @Override
    public String requestNewToken() {
        log.info("Solicitando nuevo token de acceso a Bancolombia");

        try {
            // Desactivar tokens anteriores
            masterBancolombiaTokenRepository.findAllByIsActiveTrue();

            // Preparar request
            MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
            formData.add("grant_type", "client_credentials");
            formData.add("client_id", bancolombiaProperties.getSandbox().getAuth().getClientId());
            formData.add("client_secret", bancolombiaProperties.getSandbox().getAuth().getClientSecret());
            formData.add("scope", bancolombiaProperties.getSandbox().getAuth().getScope());

            // Realizar solicitud
            TokenResponseDTO tokenResponse = bancolombiaWebClient
                    .post()
                    .uri(bancolombiaProperties.getSandbox().getAuth().getTokenUrl())
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(BodyInserters.fromFormData(formData))
                    .retrieve()
                    .bodyToMono(TokenResponseDTO.class)
                    .retryWhen(Retry.backoff(
                                    bancolombiaProperties.getSandbox().getApi().getMaxRetries(),
                                    Duration.ofSeconds(1))
                            .filter(throwable -> !(throwable instanceof WebClientResponseException.Unauthorized)))
                    .timeout(Duration.ofSeconds(bancolombiaProperties.getSandbox().getApi().getTimeoutSeconds()))
                    .onErrorMap(TimeoutException.class, ex ->
                            new BancolombiaTimeoutException("Timeout al solicitar token de Bancolombia", ex))
                    .onErrorMap(WebClientResponseException.Unauthorized.class, ex ->
                            new BancolombiaAuthenticationException("Credenciales inválidas para Bancolombia", ex))
                    .onErrorMap(WebClientResponseException.Forbidden.class, ex ->
                            new BancolombiaAuthorizationException("Acceso denegado por Bancolombia", ex))
                    .onErrorMap(WebClientResponseException.TooManyRequests.class, ex ->
                            new BancolombiaRateLimitException("Límite de tasa excedido en Bancolombia", ex))
                    .onErrorMap(WebClientResponseException.class, ex ->
                            new BancolombiaApiException("Error en API de Bancolombia: " + ex.getMessage(), ex.getStatusCode().value(), ex))
                    .block();

            if (tokenResponse == null) {
                throw new BancolombiaApiException("Respuesta vacía al solicitar token", 500);
            }

            // Guardar token en base de datos
            BancolombiaToken token = BancolombiaToken.builder()
                    .accessToken(tokenResponse.getAccessToken())
                    .tokenType(tokenResponse.getTokenType())
                    .expiresIn(tokenResponse.getExpiresIn())
                    .scope(tokenResponse.getScope())
                    .refreshToken(tokenResponse.getRefreshToken())
                    .isActive(true)
                    .build();

            masterBancolombiaTokenRepository.save(token);

            log.info("Token de Bancolombia obtenido y guardado exitosamente");
            return token.getAccessToken();

        } catch (Exception e) {
            log.error("Error al solicitar token de Bancolombia", e);
            if (e instanceof BancolombiaException) {
                throw e;
            }
            throw new BancolombiaApiException("Error inesperado al solicitar token: " + e.getMessage(), 500, e);
        }
    }

    /**
     * Invalida el token actual
     */
    @Override
    public void invalidateToken() {
        log.info("Invalidando token actual de Bancolombia");
        masterBancolombiaTokenRepository.findAllByIsActiveTrue();
    }

    /**
     * Limpia tokens expirados (método para tareas programadas)
     */
    @Override
    public void cleanupExpiredTokens() {
        log.debug("Limpiando tokens expirados de Bancolombia");

        LocalDateTime currentTime = LocalDateTime.now();

        // Desactivar tokens expirados
        List<BancolombiaToken> expirados = masterBancolombiaTokenRepository
                .findAllByIsActiveTrueAndExpiresAtBefore(currentTime);

        expirados.forEach(token -> token.setIsActive(false));
        masterBancolombiaTokenRepository.saveAll(expirados);

        // Eliminar tokens antiguos (más de 7 días)
        LocalDateTime cutoffDate = currentTime.minusDays(7);
        List<BancolombiaToken> antiguos = masterBancolombiaTokenRepository
                .findAllByCreatedAtBefore(cutoffDate);

        masterBancolombiaTokenRepository.deleteAll(antiguos);

        log.debug("Tokens de Bancolombia limpiados: {} desactivados, {} eliminados", expirados.size(), antiguos.size());
    }

    /**
     * Verifica si hay un token válido disponible
     */
    @Override
    public boolean hasValidToken() {
        LocalDateTime currentTime = LocalDateTime.now();
        return slaveBancolombiaTokenRepository.findFirstByIsActiveTrueAndExpiresAtAfterOrderByCreatedAtDesc(currentTime).isPresent();
    }

    /**
     * Obtiene información del token actual
     */
    @Override
    public BancolombiaToken getCurrentToken() {
        LocalDateTime currentTime = LocalDateTime.now();
        return slaveBancolombiaTokenRepository.findFirstByIsActiveTrueAndExpiresAtAfterOrderByCreatedAtDesc(currentTime).orElse(null);
    }

    private void deactivateAllActiveTokens() {
        List<BancolombiaToken> activeTokens = masterBancolombiaTokenRepository.findAllByIsActiveTrue();
        activeTokens.forEach(token -> token.setIsActive(false));
        masterBancolombiaTokenRepository.saveAll(activeTokens);
    }

}
