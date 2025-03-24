package org.kuenteco.backend.controller;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.auth.ChangePasswordDTO;
import org.kuenteco.backend.dto.auth.LoginUserDTO;
import org.kuenteco.backend.dto.auth.NewUserDTO;
import org.kuenteco.backend.dto.auth.VerificationCodeDTO;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.service.jwt.AuthService;
import org.kuenteco.backend.service.jwt.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@RequestMapping("/v1/auth")
@AllArgsConstructor
// @CrossOrigin("http://")
public class AuthController {
    private final UserService userService;
    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<ApiMessage> login(@Valid @RequestBody LoginUserDTO loginUserDTO, BindingResult bindingResult,
            HttpServletResponse response) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(new ApiMessage("Invalid dates"));
        }

        try {
            String token = authService.authenticate(loginUserDTO.getEmail(), loginUserDTO.getPassword(), response);
            return ResponseEntity.ok(new ApiMessage(
                    "Logged in successfully with email: " + loginUserDTO.getEmail() + " and token: " + token));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiMessage("review your credentials"));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<ApiMessage> register(@Valid @RequestBody NewUserDTO newUserDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(new ApiMessage("Invalid data"));
        }
        try {
            authService.registerUser(newUserDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(new ApiMessage("Register Successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PostMapping("/send-verification-code")
    public ResponseEntity<ApiMessage> sendVerificationCode(
            @Valid @RequestBody VerificationCodeDTO verificationCodeDTO) {
        try {
            authService.sendVerificationEmail(verificationCodeDTO);
            return ResponseEntity.ok(new ApiMessage("Código de verificación enviado"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiMessage("Error al enviar el código de verificación"));
        }
    }

    @PostMapping("/validate-verification-code")
    public ResponseEntity<ApiMessage> validateVerificationCode(
            @Valid @RequestBody VerificationCodeDTO verificationCodeDTO) {
        boolean isValid = authService.validateVerificationCode(verificationCodeDTO);
        if (isValid) {
            return ResponseEntity.ok(new ApiMessage("Código de verificación válido"));
        } else {
            return ResponseEntity.badRequest().body(new ApiMessage("Código de verificación inválido"));
        }
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiMessage> changePassword(@Valid @RequestBody ChangePasswordDTO changePasswordDTO) {
        try {
            // Validar que las contraseñas coincidan
            if (!changePasswordDTO.getNewPassword().equals(changePasswordDTO.getConfirmNewPassword())) {
                return ResponseEntity.badRequest().body(new ApiMessage("Las contraseñas no coinciden"));
            }

            // Cambiar la contraseña
            String message = authService.validateChangePassword(changePasswordDTO.getVerificationCodeDTO(),
                    changePasswordDTO.getNewPassword());
            return ResponseEntity.ok(new ApiMessage(message));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @GetMapping("/check-auth")
    public ResponseEntity<String> checkAuth() {
        return ResponseEntity.ok().body("authenticated");
    }

    @GetMapping("/user/details")
    public ResponseEntity<User> getAuthenticatedUser() {
        User user = userService.getUserDetails();

        return ResponseEntity.ok(user);
    }

}
