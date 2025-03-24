package org.kuenteco.backend.exception;

import org.kuenteco.backend.dto.ApiMessage;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Objects;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiMessage> handleValidationException(MethodArgumentNotValidException ex) {
        String errorMessage = Objects
                .requireNonNull(Objects.requireNonNull(ex.getBindingResult().getFieldError()).getDefaultMessage());
        return ResponseEntity.badRequest().body(new ApiMessage(errorMessage));
    }
}
