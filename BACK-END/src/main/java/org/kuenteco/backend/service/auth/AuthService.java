package org.kuenteco.backend.service.auth;

import jakarta.servlet.http.HttpServletResponse;
import org.kuenteco.backend.dto.auth.NewUserDTO;
import org.kuenteco.backend.dto.auth.SendVerificationCodeDTO;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface AuthService {
    //Metodos para registro e inicio de sesión
    TokenResponseDTO authenticate(String nameOrEmail, String password, HttpServletResponse response);

    void registerUser(NewUserDTO newUserDTO);

    // Métodos de verificación
    void sendVerificationEmail(SendVerificationCodeDTO verificationCodeDTO, boolean isRegistration) throws IOException;
    boolean validateVerificationCode(String email, String code);
    void activateUser(String email);

    // Métodos de cambio de contraseña
    String changePasswordWithVerification(String email, String code, String newPassword);

    // Cierre de Sesión
    void logout(String token, HttpServletResponse response);

    //Metodos para la imagen de foto de perfil
    ImageDTO saveImage(MultipartFile image, String token, HttpServletResponse response);
    ImageDTO updateImage(MultipartFile image, String token, HttpServletResponse response);
    void deleteImage(String token, HttpServletResponse response);

}