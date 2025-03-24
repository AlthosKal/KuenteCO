package org.kuenteco.backend.service.jwt;

import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.dto.auth.NewUserDTO;
import org.kuenteco.backend.dto.auth.VerificationCodeDTO;

import java.io.IOException;

public interface AuthService {
    String authenticate(String username, String password, HttpServletResponse response);

    void registerUser(NewUserDTO newUserDTO);

    void sendVerificationEmail(VerificationCodeDTO verificationCodeDTO) throws IOException;

    boolean validateVerificationCode(VerificationCodeDTO verificationCodeDTO);

    String validateChangePassword(VerificationCodeDTO verificationCodeDTO, String newPassword);

    String changePassword(String newPassword);
}
