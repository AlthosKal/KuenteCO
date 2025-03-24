package org.kuenteco.backend.exception;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CustomErrorResponse {
    private int status; // Código de estado HTTP
    private String message; // Mensaje descriptivo del error
    private LocalDateTime timestamp; // Momento en que ocurrió el error
}
