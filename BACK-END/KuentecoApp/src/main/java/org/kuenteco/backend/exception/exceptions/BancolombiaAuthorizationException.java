package org.kuenteco.backend.exception.exceptions;

// Excepción para problemas de autorización
public class BancolombiaAuthorizationException extends BancolombiaException {
    public BancolombiaAuthorizationException(String message) {
        super(message, "BANCOLOMBIA_AUTHORIZATION_ERROR", 403);
    }

    public BancolombiaAuthorizationException(String message, Throwable cause) {
        super(message, "BANCOLOMBIA_AUTHORIZATION_ERROR", 403, cause);
    }
}