package org.kuenteco.backend.dto.auth;

import jakarta.validation.constraints.Email;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VerificationCodeDTO {
    @Email
    private String email;
    private String code;
}