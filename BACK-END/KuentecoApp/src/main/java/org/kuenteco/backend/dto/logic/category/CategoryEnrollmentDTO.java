package org.kuenteco.backend.dto.logic.category;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CategoryEnrollmentDTO {
    // Listar Ides
    @NotBlank private String userEmail;
    @NotBlank private String profileEmail;
    @NotBlank private String categoryName;
}
