package org.kuenteco.backend.dto.subscription.request.api;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;
import java.time.YearMonth;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.validations.PayMethodConstraint;
import org.kuenteco.backend.validations.ValidCardExpiration;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@PayMethodConstraint
@ValidCardExpiration
public class TokenizeCardRequestDTO {
    @NotBlank(message = "El número de tarjeta es obligatorio")
    @Pattern(regexp = "^\\d{13,19}$", message = "Número de tarjeta inválido")
    private String cardNumber;

    @NotBlank(message = "El CVC es obligatorio")
    @Pattern(regexp = "^\\d{3,4}$", message = "CVC inválido")
    private String cvc;

    @NotBlank(message = "El mes de expiración es obligatorio")
    @Pattern(regexp = "^(0[1-9]|1[0-2])$", message = "Mes inválido (01-12)")
    private String expiryMonth;

    @NotBlank(message = "El año de expiración es obligatorio")
    @Pattern(
            regexp = "^(20[2-9][0-9]|2[1-9][0-9][0-9])$",
            message = "Año inválido (mínimo año actual)")
    private String expiryYear;

    @NotBlank(message = "El nombre del titular es obligatorio")
    private String cardHolder;

    /**
     * Obtiene la fecha de expiración como LocalDate para validaciones Se usa el primer día del mes
     * para la comparación
     */
    @JsonIgnore
    public LocalDate getExpirationDate() {
        try {
            int year = Integer.parseInt(expiryYear);
            int month = Integer.parseInt(expiryMonth);
            return LocalDate.of(year, month, 1);
        } catch (NumberFormatException e) {
            return null; // Las validaciones de Pattern capturarán esto
        }
    }

    /** Obtiene el YearMonth de expiración para comparaciones más precisas */
    @JsonIgnore
    public YearMonth getExpirationYearMonth() {
        try {
            return YearMonth.of(Integer.parseInt(expiryYear), Integer.parseInt(expiryMonth));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Valida si la tarjeta no está vencida */
    @JsonIgnore
    public boolean isNotExpired() {
        YearMonth expiration = getExpirationYearMonth();
        return expiration != null && !expiration.isBefore(YearMonth.now());
    }
}
