package org.kuenteco.backend.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.UserType;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewUserDTO {
    @NotBlank(message = "Nombre es requerido")
    @Size(min = 3, max = 50, message = "El nombre debe tener entre 3 y 50 caracteres")
    @Pattern(
            regexp = "^[a-zA-ZñÑáéíóúÁÉÍÓÚ\\s]+$",
            message = "El nombre solo puede contener letras y espacios")
    private String username;

    @Email(message = "El formato del correo no es válido")
    @NotBlank(message = "El correo es requerido")
    @Size(max = 255, message = "El correo no puede exceder 255 caracteres")
    public String email;

    @NotBlank(message = "La contraseña es requerida")
    @Size(min = 8, max = 128, message = "La contraseña debe tener entre 8 y 128 caracteres")
    @Pattern(
            regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).*$",
            message =
                    "La contraseña debe contener al menos: 1 número, 1 minúscula, 1 mayúscula y 1 carácter especial")
    public String password;

    @NotNull(message = "El tipo de Usuario es requerido")
    private UserType type;
}
