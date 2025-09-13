package org.kuenteco.backend.service.auth;

import org.kuenteco.backend.dto.auth.RecaptchaResponseDTO;

public interface RecaptchaService {
    RecaptchaResponseDTO verify(String token);
}
