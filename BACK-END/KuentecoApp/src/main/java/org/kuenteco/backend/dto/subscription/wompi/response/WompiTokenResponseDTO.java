package org.kuenteco.backend.dto.subscription.wompi.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.subscription.wompi.response.extra.TokenData;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WompiTokenResponseDTO {
    private TokenData data;
}
