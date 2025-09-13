package org.kuenteco.backend.dto.auth;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecaptchaResponseDTO {
    private boolean success;

    @JsonProperty("challenge_ts")
    private String challenge_ts;

    private String hostname;

    @JsonProperty("error-codes")
    private List<String> errorCodes;
}
