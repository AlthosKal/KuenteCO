package org.kuenteco.backend.dto.auth;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecaptchaRequestDTO {
    private String token;
}
