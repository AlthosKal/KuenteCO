package org.kuenteco.backend.exception.exceptions;

public class BancolombiaApiException extends BancolombiaException {
    public BancolombiaApiException(String message, int httpStatus) {
        super(message, "BANCOLOMBIA_API_ERROR", httpStatus);
    }

    public BancolombiaApiException(String message, int httpStatus, Throwable cause) {
        super(message, "BANCOLOMBIA_API_ERROR", httpStatus, cause);
    }
}
