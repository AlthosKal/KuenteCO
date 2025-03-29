package org.kuenteco.backend.service.jwt;

import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.dto.auth.NewUserDTO;
import org.kuenteco.backend.dto.auth.SendVerificationCodeDTO;

import java.io.IOException;

public interface AuthService {
    String authenticate(String username, String password, HttpServletResponse response);

    void registerUser(NewUserDTO newUserDTO);

    // Métodos de verificación
    void sendVerificationEmail(SendVerificationCodeDTO verificationCodeDTO, boolean isRegistration) throws IOException;

    boolean validateVerificationCode(String email, String code);

    void activateUser(String email);

    // Métodos de cambio de contraseña
    String changePasswordWithVerification(String email, String code, String newPassword);

    // Cierre de Sesión
    void logout(String token, HttpServletResponse response);
}