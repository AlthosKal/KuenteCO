package org.kuenteco.backend.exception.exceptions;

public class TokenizationException extends RuntimeException {
    public TokenizationException(String message) {
        super(message);
    }

    public TokenizationException(String message, Throwable cause) {
        super(message, cause);
    }
}
