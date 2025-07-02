package org.kuenteco.backend.dto.subscription.request.extra;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WompiShippingAddress {
    @JsonProperty("address_line_1")
    private String addressLine1;
    private String country;
    private String region;
    private String city;
    private String name;
    @JsonProperty("phone_number")
    private String phoneNumber;
}
