package org.kuenteco.backend.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.UserType;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewUserDTO {
    @NotBlank(message = "Nombre es requerido")
    private String username;

    @Email
    @NotBlank(message = "El correo es requerido")
    public String email;

    @NotBlank(message = "La contraseña es requerida")
    public String password;

    @NotNull(message = "El tipo de Usuario es requerido")
    private UserType type;
}
