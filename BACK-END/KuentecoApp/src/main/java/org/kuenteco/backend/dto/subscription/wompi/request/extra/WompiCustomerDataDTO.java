package org.kuenteco.backend.dto.subscription.wompi.request.extra;

import com.fasterxml.jackson.annotation.JsonProperty;
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
public class WompiCustomerDataDTO {
    @JsonProperty("phone_number")
    @NotBlank(message = "El número de teléfono es obligatorio")
    @Pattern(regexp = "^\\+?[0-9]{10,15}$", message = "Número de teléfono inválido")
    private String phoneNumber;

    @JsonProperty("full_name")
    @NotBlank(message = "El nombre completo es obligatorio")
    @Size(max = 150, message = "El nombre completo no puede exceder 150 caracteres")
    private String fullName;
}
