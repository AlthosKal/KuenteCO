package org.kuenteco.backend.dto.logic.transaction.bancolombia.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO para token de autenticación
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TokenResponseDTO {
    @JsonProperty("access_token")
    private String accessToken;

    @JsonProperty("token_type")
    private String tokenType;

    @JsonProperty("expires_in")
    private Long expiresIn;

    private String scope;

    @JsonProperty("refresh_token")
    private String refreshToken;
}
