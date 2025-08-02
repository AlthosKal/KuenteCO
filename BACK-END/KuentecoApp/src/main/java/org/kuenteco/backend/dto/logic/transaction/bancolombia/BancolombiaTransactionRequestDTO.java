package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BancolombiaTransactionRequestDTO {
    @NotBlank(message = "El producto es requerido")
    @Size(min = 1, max = 50, message = "El producto debe tener entre 1 y 50 caracteres")
    private String product; // e.g., "bnpl"

    @NotBlank(message = "El tipo de identificación es requerido")
    @Size(
            min = 1,
            max = 10,
            message = "El tipo de identificación debe tener entre 1 y 10 caracteres")
    private String identificationType; // "NIT"

    @NotBlank(message = "El número de identificación es requerido")
    @Size(
            min = 1,
            max = 20,
            message = "El número de identificación debe tener entre 1 y 20 caracteres")
    private String identificationNumber; // e.g., "1999012334"

    @NotBlank(message = "La fecha inicial es requerida")
    @Pattern(
            regexp = "^\\d{2}/\\d{2}/\\d{4}$",
            message = "La fecha inicial debe tener formato dd/MM/yyyy")
    private String initialDate; // "dd/MM/yyyy"

    @NotBlank(message = "La fecha final es requerida")
    @Pattern(
            regexp = "^\\d{2}/\\d{2}/\\d{4}$",
            message = "La fecha final debe tener formato dd/MM/yyyy")
    private String finalDate; // "dd/MM/yyyy"

    @NotBlank(message = "El intervalo de tiempo es requerido")
    @Size(min = 1, max = 5, message = "El intervalo de tiempo debe tener entre 1 y 5 caracteres")
    private String timeSpan; // "D"
}
