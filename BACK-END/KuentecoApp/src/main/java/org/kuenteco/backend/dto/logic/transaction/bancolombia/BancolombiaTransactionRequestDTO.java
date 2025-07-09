package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BancolombiaTransactionRequestDTO {
    private String product; // e.g., "bnpl"
    private String identificationType; // "NIT"
    private String identificationNumber; // e.g., "1999012334"
    private String initialDate; // "dd/MM/yyyy"
    private String finalDate; // "dd/MM/yyyy"
    private String timeSpan; // "D"
}
