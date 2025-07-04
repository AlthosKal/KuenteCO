package org.kuenteco.backend.dto.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LoginDTO {
    @NotBlank(message = "EL nombre o correo es requerido")
    public String nameOrEmail;

    @NotBlank(message = "La contraseña es requerida")
    public String password;
}
