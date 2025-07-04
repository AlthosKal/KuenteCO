package org.kuenteco.backend.dto.subscription.wompi.response.extra;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MerchantData {
    private String name;
    private String email;

    @JsonProperty("contact_name")
    private String contactName;

    @JsonProperty("phone_number")
    private String phoneNumber;

    @JsonProperty("active_ecommerce")
    private Boolean activeEcommerce;
}
