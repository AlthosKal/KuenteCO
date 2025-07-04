package org.kuenteco.backend.exception.exceptions;

public class WebhookException extends RuntimeException {
    public WebhookException(String message) {
        super(message);
    }
}
