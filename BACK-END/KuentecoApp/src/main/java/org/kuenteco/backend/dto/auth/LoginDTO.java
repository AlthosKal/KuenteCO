package org.kuenteco.backend.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class LoginDTO {
    @NotBlank(message = "El nombre o correo es requerido")
    @Size(min = 3, max = 255, message = "El nombre o correo debe tener entre 3 y 255 caracteres")
    public String nameOrEmail;

    @NotBlank(message = "La contraseña es requerida")
    @Size(
            min = 1,
            max = 128,
            message = "La contraseña no puede estar vacía o exceder 128 caracteres")
    public String password;
}
