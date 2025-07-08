package org.kuenteco.backend.service.logic.transaction.bancolombia;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.AccountDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.TransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.AccountsResponseDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.TransactionsResponseDTO;
import org.kuenteco.backend.exception.exceptions.*;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.TimeoutException;

@Service
@RequiredArgsConstructor
@Slf4j
public class ConectaServiceImpl implements ConectaService {
    private final WebClient bancolombiaWebClient;
    private final BancolombiaAuthService authService;
    private final BancolombiaProperties bancolombiaProperties;

    /**
     * Obtiene todas las cuentas del usuario
     */
    @Override
    public List<AccountDTO> getAccounts() {
        log.info("Obteniendo cuentas de Bancolombia Conecta");

        try {
            String token = authService.getValidToken();

            AccountsResponseDTO response = bancolombiaWebClient
                    .get()
                    .uri(bancolombiaProperties.getSandbox().getApi().getEndpoints().getAccounts())
                    .header("Authorization", "Bearer " + token)
                    .retrieve()
                    .bodyToMono(AccountsResponseDTO.class)
                    .retryWhen(Retry.backoff(
                                    bancolombiaProperties.getSandbox().getApi().getMaxRetries(),
                                    Duration.ofSeconds(1))
                            .filter(this::isRetryableError))
                    .timeout(Duration.ofSeconds(bancolombiaProperties.getSandbox().getApi().getTimeoutSeconds()))
                    .onErrorMap(this::mapWebClientException)
                    .block();

            if (response == null || response.getAccounts() == null) {
                log.warn("Respuesta vacía al obtener cuentas");
                return List.of();
            }

            log.info("Obtenidas {} cuentas de Bancolombia", response.getAccounts().size());
            return response.getAccounts();

        } catch (Exception e) {
            log.error("Error al obtener cuentas de Bancolombia", e);
            if (e instanceof BancolombiaException) {
                throw e;
            }
            throw new BancolombiaApiException("Error inesperado al obtener cuentas: " + e.getMessage(), 500, e);
        }
    }

    /**
     * Obtiene una cuenta específica por ID
     */
    @Override
    public AccountDTO getAccount(String accountId) {
        log.info("Obteniendo cuenta {} de Bancolombia", accountId);

        List<AccountDTO> accounts = getAccounts();
        return accounts.stream()
                .filter(account -> account.getAccountId().equals(accountId))
                .findFirst()
                .orElseThrow(() -> new BancolombiaApiException("Cuenta no encontrada: " + accountId, 404));
    }

    /**
     * Obtiene transacciones de una cuenta específica
     */
    @Override
    public List<TransactionDTO> getTransactions(String accountId, LocalDate fromDate, LocalDate toDate) {
        log.info("Obteniendo transacciones para cuenta {} desde {} hasta {}", accountId, fromDate, toDate);

        try {
            String token = authService.getValidToken();

            // Validar fechas
            if (fromDate.isAfter(toDate)) {
                throw new IllegalArgumentException("La fecha de inicio no puede ser posterior a la fecha de fin");
            }

            // Validar que la cuenta existe
            getAccount(accountId);

            String uri = bancolombiaProperties.getSandbox().getApi().getEndpoints().getTransactions()
                    .replace("{accountId}", accountId) +
                    "?from=" + fromDate.format(DateTimeFormatter.ISO_LOCAL_DATE) +
                    "&to=" + toDate.format(DateTimeFormatter.ISO_LOCAL_DATE);

            TransactionsResponseDTO response = bancolombiaWebClient
                    .get()
                    .uri(uri)
                    .header("Authorization", "Bearer " + token)
                    .retrieve()
                    .bodyToMono(TransactionsResponseDTO.class)
                    .retryWhen(Retry.backoff(
                                    bancolombiaProperties.getSandbox().getApi().getMaxRetries(),
                                    Duration.ofSeconds(1))
                            .filter(this::isRetryableError))
                    .timeout(Duration.ofSeconds(bancolombiaProperties.getSandbox().getApi().getTimeoutSeconds()))
                    .onErrorMap(this::mapWebClientException)
                    .block();

            if (response == null || response.getTransactions() == null) {
                log.warn("Respuesta vacía al obtener transacciones para cuenta {}", accountId);
                return List.of();
            }

            log.info("Obtenidas {} transacciones para cuenta {}", response.getTransactions().size(), accountId);
            return response.getTransactions();

        } catch (Exception e) {
            log.error("Error al obtener transacciones para cuenta {}", accountId, e);
            if (e instanceof BancolombiaException) {
                throw e;
            }
            throw new BancolombiaApiException("Error inesperado al obtener transacciones: " + e.getMessage(), 500, e);
        }
    }

    /**
     * Obtiene transacciones de una cuenta para el último mes
     */
    @Override
    public List<TransactionDTO> getRecentTransactions(String accountId) {
        LocalDate toDate = LocalDate.now();
        LocalDate fromDate = toDate.minusMonths(1);
        return getTransactions(accountId, fromDate, toDate);
    }

    /**
     * Obtiene transacciones de una cuenta para un período específico en días
     */
    @Override
    public List<TransactionDTO> getTransactionsForPeriod(String accountId, int days) {
        LocalDate toDate = LocalDate.now();
        LocalDate fromDate = toDate.minusDays(days);
        return getTransactions(accountId, fromDate, toDate);
    }

    /**
     * Obtiene un resumen de transacciones con la respuesta completa
     */
    @Override
    public TransactionsResponseDTO getTransactionsSummary(String accountId, LocalDate fromDate, LocalDate toDate) {
        log.info("Obteniendo resumen de transacciones para cuenta {} desde {} hasta {}", accountId, fromDate, toDate);

        try {
            String token = authService.getValidToken();

            // Validar fechas
            if (fromDate.isAfter(toDate)) {
                throw new IllegalArgumentException("La fecha de inicio no puede ser posterior a la fecha de fin");
            }

            // Validar que la cuenta existe
            getAccount(accountId);

            String uri = bancolombiaProperties.getSandbox().getApi().getEndpoints().getTransactions()
                    .replace("{accountId}", accountId) +
                    "?from=" + fromDate.format(DateTimeFormatter.ISO_LOCAL_DATE) +
                    "&to=" + toDate.format(DateTimeFormatter.ISO_LOCAL_DATE);

            TransactionsResponseDTO response = bancolombiaWebClient
                    .get()
                    .uri(uri)
                    .header("Authorization", "Bearer " + token)
                    .retrieve()
                    .bodyToMono(TransactionsResponseDTO.class)
                    .retryWhen(Retry.backoff(
                                    bancolombiaProperties.getSandbox().getApi().getMaxRetries(),
                                    Duration.ofSeconds(1))
                            .filter(this::isRetryableError))
                    .timeout(Duration.ofSeconds(bancolombiaProperties.getSandbox().getApi().getTimeoutSeconds()))
                    .onErrorMap(this::mapWebClientException)
                    .block();

            if (response == null) {
                throw new BancolombiaApiException("Respuesta vacía al obtener resumen de transacciones", 500);
            }

            log.info("Resumen de transacciones obtenido para cuenta {}", accountId);
            return response;

        } catch (Exception e) {
            log.error("Error al obtener resumen de transacciones para cuenta {}", accountId, e);
            if (e instanceof BancolombiaException) {
                throw e;
            }
            throw new BancolombiaApiException("Error inesperado al obtener resumen de transacciones: " + e.getMessage(), 500, e);
        }
    }

    /**
     * Determina si un error es recuperable para reintentos
     */
    private boolean isRetryableError(Throwable throwable) {
        if (throwable instanceof WebClientResponseException ex) {
            int statusCode = ex.getStatusCode().value();

            // No reintentar errores de autenticación/autorización
            if (statusCode == 401 || statusCode == 403) {
                return false;
            }

            // Reintentar errores del servidor y rate limiting
            return statusCode >= 500 || statusCode == 429;
        }

        // Reintentar timeouts y errores de conexión
        return throwable instanceof TimeoutException;
    }

    /**
     * Mapea excepciones de WebClient a excepciones personalizadas
     */
    private Throwable mapWebClientException(Throwable throwable) {
        if (throwable instanceof WebClientResponseException ex) {
            int statusCode = ex.getStatusCode().value();

            return switch (statusCode) {
                case 401 -> {
                    // Invalidar token actual
                    authService.invalidateToken();
                    yield new BancolombiaAuthenticationException("Token inválido o expirado", ex);
                }
                case 403 -> new BancolombiaAuthorizationException("Acceso denegado a recurso", ex);
                case 429 -> new BancolombiaRateLimitException("Límite de tasa excedido", ex);
                default -> new BancolombiaApiException("Error en API de Bancolombia: " + ex.getMessage(), statusCode, ex);
            };
        }

        if (throwable instanceof TimeoutException) {
            return new BancolombiaTimeoutException("Timeout en solicitud a Bancolombia", throwable);
        }

        return throwable;
    }
}
