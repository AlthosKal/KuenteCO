package org.kuenteco.backend.exception.exceptions;

// Excepción para problemas de autenticación
public class BancolombiaAuthenticationException extends BancolombiaException {
    public BancolombiaAuthenticationException(String message) {
        super(message, "BANCOLOMBIA_AUTH_ERROR", 401);
    }

    public BancolombiaAuthenticationException(String message, Throwable cause) {
        super(message, "BANCOLOMBIA_AUTH_ERROR", 401, cause);
    }
}