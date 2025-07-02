package org.kuenteco.backend.dto.subscription.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WompiTokenResponseDTO {
    private TokenData data;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TokenData {
        private String id;
        @JsonProperty("created_at")
        private String createdAt;
        private String brand;
        private String name;
        @JsonProperty("last_four")
        private String lastFour;
        @JsonProperty("bin")
        private String bin;
        @JsonProperty("exp_year")
        private String expYear;
        @JsonProperty("exp_month")
        private String expMonth;
        @JsonProperty("card_holder")
        private String cardHolder;
        @JsonProperty("expires_at")
        private String expiresAt;
    }
}

