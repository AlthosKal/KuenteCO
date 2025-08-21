package org.kuenteco.backend.service.logic.transaction.bancolombia;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.time.Duration;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeoutException;

import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.BancolombiaTransactionRequestDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.TransactionalInfoResponse;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.exception.exceptions.BancolombiaApiException;
import org.kuenteco.backend.exception.exceptions.BancolombiaAuthenticationException;
import org.kuenteco.backend.exception.exceptions.BancolombiaTimeoutException;
import org.kuenteco.backend.exception.exceptions.TransactionException;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.util.retry.Retry;

@Service
@Slf4j
public class ConectaServiceImpl implements ConectaService {

    private final WebClient apiWebClient;
    private final BancolombiaAuthService authService;
    private final BancolombiaProperties props;

    public ConectaServiceImpl(
            @Qualifier("apiWebClient") WebClient apiWebClient,
            BancolombiaAuthService authService,
            BancolombiaProperties props) {
        this.apiWebClient = apiWebClient;
        this.authService = authService;
        this.props = props;
    }

    @Override
    public String getTransactionsFromRequest(BancolombiaTransactionRequestDTO dto) {
        AuthCredentials credentials = getCredentials();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new TransactionException("Endpoint solo disponible para usuarios");
        }

        // 1. Construir payload según especificación exacta del curl
        Map<String, Object> payload = Map.of(
                "data", Map.of(
                        "product", dto.getProduct().toLowerCase(), // bnpl en minúsculas como en el curl
                        "thirdParty", Map.of(
                                "identification", Map.of(
                                        "type", dto.getIdentificationType().toUpperCase(), // NIT en mayúsculas
                                        "number", dto.getIdentificationNumber()
                                )
                        ),
                        "initialDate", dto.getInitialDate(),
                        "finalDate", dto.getFinalDate(),
                        "timeSpan", dto.getTimeSpan().toUpperCase() // D en mayúsculas
                )
        );

        // 2. Obtener token válido
        String token = authService.getValidToken();
        String messageId = UUID.randomUUID().toString();

        // 3. Log para debugging
        log.debug("=== DEBUGGING BANCOLOMBIA REQUEST ===");
        log.debug("Base URL: {}", apiWebClient.toString());
        log.debug("Endpoint: {}", props.getSandbox().getApi().getEndpoints().getTransactions());
        log.debug("Token (primeros 20 chars): {}", token.substring(0, Math.min(20, token.length())));
        log.debug("Message-ID: {}", messageId);
        log.debug("Payload: {}", payload);
        log.debug("=====================================");

        try {
            TransactionalInfoResponse response = apiWebClient
                    .post()
                    .uri(props.getSandbox().getApi().getEndpoints().getTransactions())
                    // ✅ Headers exactos como en el curl - Content-Type y Accept ya están en WebClient
                    .header("Accept", "application/json")
                    .header("Authorization", "Bearer " + token)
                    .header("Content-Type", "application/json")
                    .header("message-id", messageId)
                    .header("X-IBM-Client-Id", props.getSandbox().getAuth().getClientId())
                    .bodyValue(payload)
                    .retrieve()
                    .bodyToMono(TransactionalInfoResponse.class)
                    .retryWhen(
                            Retry.backoff(props.getSandbox().getApi().getMaxRetries(), Duration.ofSeconds(2))
                                    .filter(ex -> {
                                        // No reintentar en errores de autenticación
                                        return !(ex instanceof WebClientResponseException.Unauthorized) &&
                                                !(ex instanceof WebClientResponseException.Forbidden) &&
                                                !(ex instanceof WebClientResponseException.BadRequest);
                                    })
                    )
                    .timeout(Duration.ofSeconds(props.getSandbox().getApi().getTimeoutSeconds()))
                    .onErrorMap(TimeoutException.class, ex ->
                            new BancolombiaTimeoutException("Timeout al consultar transacciones", ex))
                    .onErrorMap(WebClientResponseException.BadRequest.class, ex -> {
                        log.error("❌ Error 400 Bad Request - Request malformado");
                        log.error("Response body: {}", ex.getResponseBodyAsString());
                        return new BancolombiaApiException("Request malformado: " + ex.getResponseBodyAsString(), 400, ex);
                    })
                    .onErrorMap(WebClientResponseException.Unauthorized.class, ex -> {
                        log.error("❌ Error 401: Token rechazado por Bancolombia");
                        log.error("Response body: {}", ex.getResponseBodyAsString());
                        authService.invalidateToken();
                        return new BancolombiaAuthenticationException("Token inválido o expirado", ex);
                    })
                    .onErrorMap(WebClientResponseException.Forbidden.class, ex -> {
                        log.error("❌ Error 403: Acceso denegado");
                        log.error("Response body: {}", ex.getResponseBodyAsString());
                        return new BancolombiaApiException("Acceso denegado: " + ex.getResponseBodyAsString(), 403, ex);
                    })
                    .onErrorMap(WebClientResponseException.class, ex -> {
                        log.error("❌ Error API Bancolombia - Status: {}, Body: {}",
                                ex.getStatusCode(), ex.getResponseBodyAsString());
                        return new BancolombiaApiException(
                                "Error API Bancolombia: " + ex.getResponseBodyAsString(),
                                ex.getStatusCode().value(),
                                ex);
                    })
                    .block();

            // 4. Validar respuesta
            if (response == null || response.getData() == null) {
                log.error("Respuesta nula o sin data al solicitar transactional info");
                throw new BancolombiaApiException("Respuesta inválida de Bancolombia", 500);
            }

            if (response.getData().getFileUrl() == null || response.getData().getFileUrl().isEmpty()) {
                log.error("URL de archivo no encontrada en la respuesta");
                throw new BancolombiaApiException("URL de archivo no disponible", 500);
            }

            log.info("✅ Transacciones obtenidas exitosamente. URL: {}", response.getData().getFileUrl());
            return response.getData().getFileUrl();

        } catch (Exception e) {
            log.error("❌ Error al obtener transacciones de Bancolombia: {}", e.getMessage(), e);
            if (e instanceof BancolombiaApiException
                    || e instanceof BancolombiaAuthenticationException
                    || e instanceof BancolombiaTimeoutException) {
                throw e;
            }
            throw new BancolombiaApiException("Error inesperado al consultar transacciones", 500, e);
        }
    }

    @Override
    public boolean checkHealthStatus() {
        log.info("Verificando estado de salud del servicio de información transaccional");
        try {

            String token = authService.getValidToken();
            apiWebClient
                    .head()
                    .uri(props.getSandbox().getApi().getEndpoints().getHealth())
                    .header("Authorization", "Bearer " + token)
                    .header("X-IBM-Client-Id", props.getSandbox().getAuth().getClientId())
                    .retrieve()
                    .toBodilessEntity()
                    .timeout(Duration.ofSeconds(15))
                    .onErrorMap(TimeoutException.class, ex ->
                            new BancolombiaTimeoutException("Timeout al verificar health status", ex))
                    .onErrorMap(WebClientResponseException.class, ex -> {
                        log.warn("Health check falló con status: {}", ex.getStatusCode());
                        return ex;
                    })
                    .block();

            log.info("✅ Health check exitoso - Servicio disponible");
            return true;

        } catch (BancolombiaTimeoutException e) {
            log.error("❌ Timeout en health check: {}", e.getMessage());
            return false;
        } catch (WebClientResponseException e) {
            log.warn("❌ Health check falló - Status: {}, Mensaje: {}",
                    e.getStatusCode(), e.getMessage());
            return false;
        } catch (Exception e) {
            log.error("❌ Error inesperado en health check: {}", e.getMessage(), e);
            return false;
        }
    }
}