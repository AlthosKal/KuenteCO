package org.kuenteco.backend.dto.subscription.request.extra;

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
public class WompiShippingAddressDTO {
    @JsonProperty("address_line_1")
    @NotBlank(message = "La dirección es obligatoria")
    @Size(max = 255, message = "La dirección no puede exceder 255 caracteres")
    private String addressLine1;

    @NotBlank(message = "El país es obligatorio")
    @Pattern(regexp = "^[A-Z]{2}$", message = "El código del país debe ser de 2 letras mayúsculas")
    private String country;

    @NotBlank(message = "La región es obligatoria")
    @Size(max = 100, message = "La región no puede exceder 100 caracteres")
    private String region;

    @NotBlank(message = "La ciudad es obligatoria")
    @Size(max = 100, message = "La ciudad no puede exceder 100 caracteres")
    private String city;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(max = 100, message = "El nombre no puede exceder 100 caracteres")
    private String name;

    @NotBlank(message = "El número de teléfono es obligatorio")
    @Pattern(regexp = "^\\+?[0-9]{10,15}$", message = "Número de teléfono inválido")
    @JsonProperty("phone_number")
    private String phoneNumber;
}
