package org.kuenteco.backend.dto.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DeleteUserDTO {
    @NotBlank(message = "El Id de usuario es requerido")
    private String id;
}
