package org.kuenteco.backend.exception.exceptions;

public class BancolombiaConfigurationException extends BancolombiaException {
    public BancolombiaConfigurationException(String message) {
        super(message, "BANCOLOMBIA_CONFIG_ERROR", 500);
    }

    public BancolombiaConfigurationException(String message, Throwable cause) {
        super(message, "BANCOLOMBIA_CONFIG_ERROR", 500, cause);
    }
}
