package org.kuenteco.backend.exception;

import jakarta.servlet.http.HttpServletRequest;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.exception.exceptions.*;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.validation.BindException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    // Errores de validación de campos con @Valid
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidationException(
            MethodArgumentNotValidException ex, HttpServletRequest request) {
        String errorMessage =
                ex.getBindingResult().getAllErrors().stream()
                        .map(DefaultMessageSourceResolvable::getDefaultMessage)
                        .collect(Collectors.joining("; "));

        log.warn("Error de validación: {}", errorMessage);
        return ResponseEntity.badRequest()
                .body(ApiResponse.error(errorMessage, request.getRequestURI()));
    }

    // Errores de validación para @ModelAttribute y otros
    @ExceptionHandler(BindException.class)
    public ResponseEntity<ApiResponse<Void>> handleBindException(
            BindException ex, HttpServletRequest request) {
        String errorMessage =
                ex.getBindingResult().getAllErrors().stream()
                        .map(DefaultMessageSourceResolvable::getDefaultMessage)
                        .collect(Collectors.joining("; "));

        log.warn("Error de enlace de datos: {}", errorMessage);
        return ResponseEntity.badRequest()
                .body(ApiResponse.error(errorMessage, request.getRequestURI()));
    }

    // Acceso denegado (útil si usas Spring Security)
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiResponse<Void>> handleAccessDenied(
            AccessDeniedException ex, HttpServletRequest request) {
        log.warn("Acceso denegado: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error("Acceso denegado", request.getRequestURI()));
    }

    // Método HTTP no soportado
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiResponse<Void>> handleMethodNotSupported(
            HttpRequestMethodNotSupportedException ex, HttpServletRequest request) {
        log.warn("Método no permitido: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .body(ApiResponse.error("Método no permitido", request.getRequestURI()));
    }

    // Excepciones comunes del dominio
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(
            IllegalArgumentException ex, HttpServletRequest request) {
        log.warn("Argumento inválido: {}", ex.getMessage());
        return ResponseEntity.badRequest()
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    // Errores no controlados
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleAllUncaught(
            Exception ex, HttpServletRequest request) {
        log.error("Error inesperado", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Ocurrió un error inesperado", request.getRequestURI()));
    }

    // Maneja AuthException (y BadCredentialsException convertida)
    @ExceptionHandler(AuthException.class)
    public ResponseEntity<ApiResponse<Void>> handleAuthException(
            AuthException ex, HttpServletRequest request) {
        log.warn("Error de autenticación: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(ProfileException.class)
    public ResponseEntity<ApiResponse<Void>> handleProfileException(
            ProfileException ex, HttpServletRequest request) {
        log.warn("Error de al listar los perfiles: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(SendgridException.class)
    public ResponseEntity<ApiResponse<Void>> handleSendgridException(
            SendgridException ex, HttpServletRequest request) {
        log.warn("Error de al enviar correo: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    // Maneja directamente BadCredentialsException de Spring Security
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ApiResponse<Void>> handleBadCredentials(
            BadCredentialsException ex, HttpServletRequest request) {
        log.warn(
                "Intento de autenticación fallido (Credenciales incorrectas): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Credenciales inválidas", request.getRequestURI()));
    }

    // Maneja UsernameNotFoundException de Spring Security
    @ExceptionHandler(UsernameNotFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleUsernameNotFound(
            UsernameNotFoundException ex, HttpServletRequest request) {
        log.warn("Intento de autenticación fallido (Usuarío no encontrado): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(CategoryException.class)
    public ResponseEntity<ApiResponse<Void>> handleCategoryException(
            CategoryException ex, HttpServletRequest request) {
        log.warn("Error con el servicio de Rubros: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(BudgetException.class)
    public ResponseEntity<ApiResponse<Void>> handleBudgetException(
            BudgetException ex, HttpServletRequest request) {
        log.warn("Error con el servicio de Presupuestos: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(DebtException.class)
    public ResponseEntity<ApiResponse<Void>> handleDebtException(
            DebtException ex, HttpServletRequest request) {
        log.warn("Error con el servicio de Deudas: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(NotificationException.class)
    public ResponseEntity<ApiResponse<Void>> handleNotificationException(
            NotificationException ex, HttpServletRequest request) {
        log.warn("Error con el servicio de Notificaciones: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(ExchangeRateException.class)
    public ResponseEntity<ApiResponse<Void>> handleExchangeRateException(
            ExchangeRateException ex, HttpServletRequest request) {
        log.warn("Error con el servicio de Tazas de Cambio: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(MercadoPagoException.class)
    public ResponseEntity<ApiResponse<Void>> handleMercadoPagoException(
            MercadoPagoException ex, HttpServletRequest request) {
        log.error("Error en MercadoPago: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(
                        ApiResponse.error(
                                "Error en el procesamiento del pago: " + ex.getMessage(),
                                request.getRequestURI()));
    }

    @ExceptionHandler(SubscriptionMercadoPagoException.class)
    public ResponseEntity<ApiResponse<Void>> handleSubscriptionMercadoPagoException(
            SubscriptionMercadoPagoException ex, HttpServletRequest request) {
        log.error("Error en suscripción MercadoPago: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(
                        ApiResponse.error(
                                "Error en la suscripción: " + ex.getMessage(),
                                request.getRequestURI()));
    }

    @ExceptionHandler(SubscriptionPriceException.class)
    public ResponseEntity<ApiResponse<Void>> handleSubscriptionPriceException(
            SubscriptionPriceException ex, HttpServletRequest request) {
        log.error("Error en precio de suscripción: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(
                        ApiResponse.error(
                                "Error en la configuración de precios: " + ex.getMessage(),
                                request.getRequestURI()));
    }

    // Manejo de excepciones específicas de Bancolombia
    @ExceptionHandler(BancolombiaAuthenticationException.class)
    public ResponseEntity<ApiResponse<Void>> handleBancolombiaAuthenticationException(
            BancolombiaAuthenticationException ex, HttpServletRequest request) {
        log.error("Error de autenticación con Bancolombia: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(
                        ApiResponse.error(
                                "Error de autenticación con Bancolombia: " + ex.getMessage(),
                                request.getRequestURI()));
    }

    @ExceptionHandler(BancolombiaAuthorizationException.class)
    public ResponseEntity<ApiResponse<Void>> handleBancolombiaAuthorizationException(
            BancolombiaAuthorizationException ex, HttpServletRequest request) {
        log.error("Error de autorización con Bancolombia: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(
                        ApiResponse.error(
                                "Error de autorización con Bancolombia: " + ex.getMessage(),
                                request.getRequestURI()));
    }

    @ExceptionHandler(BancolombiaRateLimitException.class)
    public ResponseEntity<ApiResponse<Void>> handleBancolombiaRateLimitException(
            BancolombiaRateLimitException ex, HttpServletRequest request) {
        log.error("Límite de tasa excedido en Bancolombia: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .body(
                        ApiResponse.error(
                                "Límite de tasa excedido. Por favor, intente más tarde.",
                                request.getRequestURI()));
    }

    @ExceptionHandler(BancolombiaTimeoutException.class)
    public ResponseEntity<ApiResponse<Void>> handleBancolombiaTimeoutException(
            BancolombiaTimeoutException ex, HttpServletRequest request) {
        log.error("Timeout en Bancolombia: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.GATEWAY_TIMEOUT)
                .body(
                        ApiResponse.error(
                                "Timeout en la conexión con Bancolombia. Por favor, intente más tarde.",
                                request.getRequestURI()));
    }

    @ExceptionHandler(BancolombiaApiException.class)
    public ResponseEntity<ApiResponse<Void>> handleBancolombiaApiException(
            BancolombiaApiException ex, HttpServletRequest request) {
        log.error("Error en API de Bancolombia: {}", ex.getMessage());

        HttpStatus status;
        String message =
                switch (ex.getHttpStatus()) {
                    case 404 -> {
                        status = HttpStatus.NOT_FOUND;
                        yield "Recurso no encontrado en Bancolombia";
                    }
                    case 400 -> {
                        status = HttpStatus.BAD_REQUEST;
                        yield "Solicitud inválida a Bancolombia";
                    }
                    case 503 -> {
                        status = HttpStatus.SERVICE_UNAVAILABLE;
                        yield "Servicio de Bancolombia no disponible";
                    }
                    default -> {
                        status = HttpStatus.INTERNAL_SERVER_ERROR;
                        yield "Error en el servicio de Bancolombia";
                    }
                };

        return ResponseEntity.status(status)
                .body(ApiResponse.error(message, request.getRequestURI()));
    }

    @ExceptionHandler(BancolombiaConfigurationException.class)
    public ResponseEntity<ApiResponse<Void>> handleBancolombiaConfigurationException(
            BancolombiaConfigurationException ex, HttpServletRequest request) {
        log.error("Error de configuración de Bancolombia: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(
                        ApiResponse.error(
                                "Error de configuración del servicio", request.getRequestURI()));
    }

    @ExceptionHandler(BancolombiaException.class)
    public ResponseEntity<ApiResponse<Void>> handleBancolombiaException(
            BancolombiaException ex, HttpServletRequest request) {
        log.error("Error general de Bancolombia: {}", ex.getMessage());

        HttpStatus status = HttpStatus.valueOf(ex.getHttpStatus());
        return ResponseEntity.status(status)
                .body(
                        ApiResponse.error(
                                "Error en el servicio de Bancolombia: " + ex.getMessage(),
                                request.getRequestURI()));
    }

    @ExceptionHandler(TransactionException.class)
    public ResponseEntity<ApiResponse<Void>> handleTransactionException(
            TransactionException ex, HttpServletRequest request) {
        log.error("Error general del servicio de Transacciones: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(ExcelException.class)
    public ResponseEntity<ApiResponse<Void>> handleExcelException(
            ExcelException ex, HttpServletRequest request) {
        log.error("Error general del servicio de Excel: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    @ExceptionHandler(ImageException.class)
    public ResponseEntity<ApiResponse<Void>> handleImageException(
            ImageException ex, HttpServletRequest request) {
        log.error("Error general del servicio de Imagenes: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }
}
