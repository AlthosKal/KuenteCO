package org.kuenteco.backend.exception.exceptions;

public class SendgridException extends RuntimeException {
    public SendgridException(String message) {
        super(message);
    }
}
