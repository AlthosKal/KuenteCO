package com.example.back_end.KuentecoChat.exception;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;
    private LocalDateTime timestamp;
    private String path; // útil para trazabilidad

    public static <T> ApiResponse<T> ok(String message, T data, String path) {
        return ApiResponse.<T> builder().success(true).message(message).data(data).timestamp(LocalDateTime.now())
                .path(path).build();
    }

    public static ApiResponse<Void> error(String message, String path) {
        return ApiResponse.<Void> builder().success(false).message(message).timestamp(LocalDateTime.now()).path(path)
                .build();
    }
}
