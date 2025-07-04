package org.kuenteco.backend.service.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.dto.auth.ChangePasswordDTO;
import org.kuenteco.backend.dto.auth.LoginDTO;
import org.kuenteco.backend.dto.auth.NewUserDTO;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;

public interface AuthService {
    // Metodos para registro e inicio de sesión
    TokenResponseDTO authenticate(LoginDTO loginUserDTO, HttpServletResponse response);

    void addUser(NewUserDTO newUserDTO);

    void activateUser(String email);

    // Métodos de cambio de contraseña
    String changePasswordWithVerification(ChangePasswordDTO changePasswordDTO);

    // Cierre de Sesión
    void logout(HttpServletRequest request, HttpServletResponse response);
}
