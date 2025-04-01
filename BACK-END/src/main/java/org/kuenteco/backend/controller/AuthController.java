package org.kuenteco.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.kuenteco.backend.jwt.JwtUtil;
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
public class AuthController {
    private final UserService userService;
    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<ApiMessage> login(@Valid @RequestBody LoginUserDTO loginUserDTO, BindingResult bindingResult,
            HttpServletResponse response) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(new ApiMessage("Invalid data"));
        }

        try {
            String token = authService.authenticate(loginUserDTO.getEmail(), loginUserDTO.getPassword(), response);
            return ResponseEntity.ok(new ApiMessage("Login successful"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<ApiMessage> register(@Valid @RequestBody NewUserDTO newUserDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(new ApiMessage("Invalid data"));
        }

        try {
            authService.registerUser(newUserDTO);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(new ApiMessage("Registration successful. Verification code sent to your email"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PostMapping("/send-verification-code")
    public ResponseEntity<ApiMessage> sendVerificationCode(
            @Valid @RequestBody SendVerificationCodeDTO sendVerificationCodeDTO,
            @RequestParam(required = false, defaultValue = "false") boolean isRegistration) {
        try {
            authService.sendVerificationEmail(sendVerificationCodeDTO, isRegistration);
            return ResponseEntity.ok(new ApiMessage("Verification code sent"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiMessage("Error sending verification code"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PostMapping("/validate-verification-code")
    public ResponseEntity<ApiMessage> validateVerificationCode(@Valid @RequestBody ValidateVerificationCodeDTO dto) {
        try {
            boolean isValid = authService.validateVerificationCode(dto.getEmail(), dto.getCode());
            if (isValid) {
                return ResponseEntity.ok(new ApiMessage("Valid verification code"));
            }
            return ResponseEntity.badRequest().body(new ApiMessage("Invalid verification code"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PostMapping("/activate-account")
    public ResponseEntity<ApiMessage> activateAccount(@Valid @RequestBody ValidateVerificationCodeDTO dto) {
        try {
            // 1. Validar el código
            if (!authService.validateVerificationCode(dto.getEmail(), dto.getCode())) {
                return ResponseEntity.badRequest().body(new ApiMessage("Invalid verification code"));
            }

            // 2. Activar la cuenta
            authService.activateUser(dto.getEmail());
            return ResponseEntity.ok(new ApiMessage("Account activated successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiMessage> changePassword(@Valid @RequestBody ChangePasswordDTO dto) {
        try {
            if (!dto.getNewPassword().equals(dto.getConfirmNewPassword())) {
                return ResponseEntity.badRequest().body(new ApiMessage("Passwords don't match"));
            }

            String message = authService.changePasswordWithVerification(dto.getEmail(), dto.getCode(),
                    dto.getNewPassword());
            return ResponseEntity.ok(new ApiMessage(message));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    // Cerrar Sesión
    @PostMapping("/logout")
    public ResponseEntity<ApiMessage> logout(HttpServletRequest request, HttpServletResponse response,
            JwtUtil jwtUtil) {
        try {
            // Obtener el token del request
            String token = jwtUtil.resolveToken(request);

            if (token != null) {
                authService.logout(token, response);
                return ResponseEntity.ok(new ApiMessage("Logout successful"));
            }
            return ResponseEntity.badRequest().body(new ApiMessage("No token provided"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @GetMapping("/check-auth")
    public ResponseEntity<String> checkAuth() {
        return ResponseEntity.ok().body("authenticated");
    }

    @GetMapping("/user/details")
    public ResponseEntity<SlaveUser> getAuthenticatedUser() {
        SlaveUser user = userService.getUserDetails();
        return ResponseEntity.ok(user);
    }
}