package org.kuenteco.backend.exception.exceptions;

// Excepción base para Bancolombia
public class BancolombiaException extends RuntimeException {
    private final String errorCode;
    private final int httpStatus;

    public BancolombiaException(String message, String errorCode, int httpStatus) {
        super(message);
        this.errorCode = errorCode;
        this.httpStatus = httpStatus;
    }

    public BancolombiaException(String message, String errorCode, int httpStatus, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
        this.httpStatus = httpStatus;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public int getHttpStatus() {
        return httpStatus;
    }
}
