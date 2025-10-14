package com.example.back_end.connector.rest.auth;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import jakarta.validation.constraints.Size;

@JsonClassDescription("Structure to request for login to user")
public record LoginDTO(
        @JsonProperty(required = true, value = "nameOrEmail")
                @JsonPropertyDescription("El nombre o correo es requerido")
                @Size(
                        min = 3,
                        max = 255,
                        message = "El nombre o correo debe tener entre 3 y 255 caracteres")
                String nameOrEmail,
        @JsonProperty(required = true, value = "password")
                @JsonPropertyDescription("La contraseña es requerida")
                @Size(
                        min = 1,
                        max = 128,
                        message = "La contraseña no puede estar vacía o exceder 128 caracteres")
                String password) {}
