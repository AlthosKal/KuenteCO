package org.kuenteco.backend.exception.exceptions;

// Excepción para límites de tasa
public class BancolombiaRateLimitException extends BancolombiaException {
    public BancolombiaRateLimitException(String message) {
        super(message, "BANCOLOMBIA_RATE_LIMIT_ERROR", 429);
    }

    public BancolombiaRateLimitException(String message, Throwable cause) {
        super(message, "BANCOLOMBIA_RATE_LIMIT_ERROR", 429, cause);
    }
}
