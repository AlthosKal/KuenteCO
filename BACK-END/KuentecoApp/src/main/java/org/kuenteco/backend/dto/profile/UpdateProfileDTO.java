package org.kuenteco.backend.dto.profile;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateProfileDTO {
    @NotNull(message = "El ID del perfil es requerido")
    @Positive(message = "El ID del perfil debe ser un número positivo")
    private Integer id;

    private String username;

    private String email;

    private boolean removeImage;
}
