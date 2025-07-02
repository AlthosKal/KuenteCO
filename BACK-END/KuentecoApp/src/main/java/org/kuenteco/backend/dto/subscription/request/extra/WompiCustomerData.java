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
public class WompiCustomerData {
    @JsonProperty("phone_number")
    private String phoneNumber;
    @JsonProperty("full_name")
    private String fullName;
}
