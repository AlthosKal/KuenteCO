package org.kuenteco.backend.service.email;

import org.kuenteco.backend.dto.auth.SendVerificationCodeDTO;
import org.kuenteco.backend.dto.auth.ValidateVerificationCodeDTO;

public interface SendgridService {
    void sendVerificationEmail(
            SendVerificationCodeDTO sendVerificationCodeDTO, boolean isRegistration);

    boolean validateVerificationCode(ValidateVerificationCodeDTO validateVerificationCodeDTO);
}
