package org.kuenteco.backend.dto.logic.category;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.validation.FutureDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewCategoryDTO {
    @Positive(message = "El ID del presupuesto debe ser un número positivo")
    private Integer budgetId;

    @Valid
    @NotNull(message = "La descripción de la categoría es requerida")
    private DescriptionCategory description;

    @NotNull(message = "La fecha de inicio es requerida")
    @FutureDate(
            minDaysInFuture = 0,
            maxDaysInFuture = 3650,
            message = "La fecha de inicio debe ser válida (hasta 10 años)")
    private LocalDateTime startDate;

    @NotNull(message = "La fecha de finalización es requerida")
    @FutureDate(
            minDaysInFuture = 0,
            maxDaysInFuture = 3650,
            message = "La fecha de finalización debe ser válida (hasta 10 años)")
    private LocalDateTime finishDate;
}
