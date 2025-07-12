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
import org.kuenteco.backend.exception.exceptions.*;
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
        // 1. Construir payload según especificación
        Map<String, Object> payload =
                Map.of(
                        "data",
                        Map.of(
                                "product", dto.getProduct(),
                                "thirdParty",
                                        Map.of(
                                                "identification",
                                                Map.of(
                                                        "type", dto.getIdentificationType(),
                                                        "number", dto.getIdentificationNumber())),
                                "initialDate", dto.getInitialDate(),
                                "finalDate", dto.getFinalDate(),
                                "timeSpan", dto.getTimeSpan()));

        // 2. Obtener token válido
        String token = authService.getValidToken();
        String messageId = UUID.randomUUID().toString();

        try {
            // 3. Realizar llamada al endpoint transaccional
            TransactionalInfoResponse response =
                    apiWebClient
                            .post()
                            // 🔧 CORRECCIÓN: No duplicar basePath, solo usar el endpoint específico
                            .uri(
                                    uriBuilder ->
                                            uriBuilder
                                                    .path(
                                                            props.getSandbox()
                                                                    .getApi()
                                                                    .getEndpoints()
                                                                    .getTransactions())
                                                    .build())
                            .header("Authorization", "Bearer " + token)
                            .header("message-id", messageId)
                            // Content-Type y Accept ya están configurados en el WebClient
                            .bodyValue(payload)
                            .retrieve()
                            .bodyToMono(TransactionalInfoResponse.class)
                            // 🔧 MEJORA: Agregar retry y timeout
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
                            // 🔧 MEJORA: Manejo de errores específico
                            .onErrorMap(
                                    TimeoutException.class,
                                    ex ->
                                            new BancolombiaTimeoutException(
                                                    "Timeout al consultar transacciones", ex))
                            .onErrorMap(
                                    WebClientResponseException.Unauthorized.class,
                                    ex -> {
                                        // Token expirado, invalidar y relanzar error
                                        authService.invalidateToken();
                                        return new BancolombiaAuthenticationException(
                                                "Token inválido o expirado", ex);
                                    })
                            .onErrorMap(
                                    WebClientResponseException.class,
                                    ex ->
                                            new BancolombiaApiException(
                                                    "Error API Bancolombia: " + ex.getMessage(),
                                                    ex.getStatusCode().value(),
                                                    ex))
                            .block();

            // 4. Validar respuesta
            if (response == null || response.getData() == null) {
                log.error("Respuesta nula o sin data al solicitar transactional info");
                throw new BancolombiaApiException("Respuesta inválida de Bancolombia", 500);
            }

            if (response.getData().getFileUrl() == null
                    || response.getData().getFileUrl().isEmpty()) {
                log.error("URL de archivo no encontrada en la respuesta");
                throw new BancolombiaApiException("URL de archivo no disponible", 500);
            }

            log.info(
                    "Transacciones obtenidas exitosamente. URL: {}",
                    response.getData().getFileUrl());
            return response.getData().getFileUrl();

        } catch (Exception e) {
            log.error("Error al obtener transacciones de Bancolombia: {}", e.getMessage(), e);
            if (e instanceof BancolombiaApiException
                    || e instanceof BancolombiaAuthenticationException
                    || e instanceof BancolombiaTimeoutException) {
                throw e;
            }
            throw new BancolombiaApiException(
                    "Error inesperado al consultar transacciones", 500, e);
        }
    }
}
