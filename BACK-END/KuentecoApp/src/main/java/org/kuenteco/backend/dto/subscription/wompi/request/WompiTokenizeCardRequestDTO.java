package org.kuenteco.backend.dto.subscription.wompi.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WompiTokenizeCardRequestDTO {
    private String number;
    private String cvc;

    @JsonProperty("exp_month")
    private String expMonth;

    @JsonProperty("exp_year")
    private String expYear;

    @JsonProperty("card_holder")
    private String cardHolder;
}
