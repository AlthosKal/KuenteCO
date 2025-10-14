package com.example.back_end.dto.request;

import jakarta.validation.constraints.NotBlank;

public record InitiateCallDTO(@NotBlank(message = "El número es requerido") String phoneNumber) {}
