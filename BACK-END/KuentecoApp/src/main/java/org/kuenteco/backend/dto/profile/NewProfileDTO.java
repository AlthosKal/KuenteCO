package org.kuenteco.backend.dto.profile;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewProfileDTO {
    @NotBlank(message = "El nombre de usuario es requerido")
    private String username;

    @Email(message = "El formato del correo no es válido")
    private String email;

    @NotBlank(message = "La contraseña es requerida")
    private String password;
}
