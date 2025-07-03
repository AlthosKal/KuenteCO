package org.kuenteco.backend.dto.subscription.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.subscription.response.extra.TokenData;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WompiTokenResponseDTO {
    private TokenData data;
}
