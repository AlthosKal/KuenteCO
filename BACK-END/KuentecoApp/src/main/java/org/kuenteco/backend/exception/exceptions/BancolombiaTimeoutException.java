package org.kuenteco.backend.exception.exceptions;

public class BancolombiaTimeoutException extends BancolombiaException {
    public BancolombiaTimeoutException(String message) {
        super(message, "BANCOLOMBIA_TIMEOUT_ERROR", 504);
    }

    public BancolombiaTimeoutException(String message, Throwable cause) {
        super(message, "BANCOLOMBIA_TIMEOUT_ERROR", 504, cause);
    }
}
