package org.kuenteco.backend.dto.profile;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.image.ImageDTO;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateProfileDTO {
    @NotNull(message = "El ID del perfil es requerido")
    @Positive(message = "El ID del perfil debe ser un número positivo")
    private Integer id;

    @NotBlank(message = "El nombre de usuario es requerido")
    @Size(min = 3, max = 50, message = "El nombre de usuario debe tener entre 3 y 50 caracteres")
    @Pattern(
            regexp = "^[a-zA-ZñÑáéíóúÁÉÍÓÚ\\s]+$",
            message = "El nombre solo puede contener letras y espacios")
    private String username;

    @Email(message = "El formato del correo no es válido")
    @NotBlank(message = "El correo es requerido")
    @Size(max = 255, message = "El correo no puede exceder 255 caracteres")
    private String email;

    @NotBlank(message = "La contraseña es requerida")
    @Size(min = 8, max = 128, message = "La contraseña debe tener entre 8 y 128 caracteres")
    @Pattern(
            regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).*$",
            message =
                    "La contraseña debe contener al menos: 1 número, 1 minúscula, 1 mayúscula y 1 carácter especial")
    private String password;

    private ImageDTO image;
}
