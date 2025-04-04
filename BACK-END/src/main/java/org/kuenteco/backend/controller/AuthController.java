package org.kuenteco.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.kuenteco.backend.jwt.JwtUtil;
import org.kuenteco.backend.service.auth.AuthService;
import org.kuenteco.backend.service.auth.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    @PostMapping("/login")
    public ResponseEntity<ApiMessage> login(@Valid @RequestBody LoginUserDTO loginUserDTO, BindingResult bindingResult,
            HttpServletResponse response) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(new ApiMessage("Datos Invalidos"));
        }

        try {
            String token = authService.authenticate(loginUserDTO.getEmail(), loginUserDTO.getPassword(), response);
            return ResponseEntity.ok(new ApiMessage("Inicio de sesión exitoso"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<ApiMessage> register(@Valid @RequestBody NewUserDTO newUserDTO, BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(new ApiMessage("Datos Invalidos"));
        }

        try {
            authService.registerUser(newUserDTO);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(new ApiMessage("Registro exitoso. Codigo de verificación enviado al correo"));
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
            return ResponseEntity.ok(new ApiMessage("Código de verificación enviado"));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiMessage("Error enviando código de verificación"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PostMapping("/validate-verification-code")
    public ResponseEntity<ApiMessage> validateVerificationCode(@Valid @RequestBody ValidateVerificationCodeDTO dto) {
        try {
            boolean isValid = authService.validateVerificationCode(dto.getEmail(), dto.getCode());
            if (isValid) {
                return ResponseEntity.ok(new ApiMessage("Código de verificación valido"));
            }
            return ResponseEntity.badRequest().body(new ApiMessage("Código de verificación valido"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PostMapping("/activate-account")
    public ResponseEntity<ApiMessage> activateAccount(@Valid @RequestBody ValidateVerificationCodeDTO dto) {
        try {
            // 1. Validar el código
            if (!authService.validateVerificationCode(dto.getEmail(), dto.getCode())) {
                return ResponseEntity.badRequest().body(new ApiMessage("Código de verificación valido"));
            }

            // 2. Activar la cuenta
            authService.activateUser(dto.getEmail());
            return ResponseEntity.ok(new ApiMessage("Cuenta activada correctamente"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiMessage> changePassword(@Valid @RequestBody ChangePasswordDTO dto) {

        try {
            if (dto.getCode() == null || dto.getCode().trim().isEmpty()) {
                log.error("Error: Código de verificación vació");
                return ResponseEntity.badRequest().body(new ApiMessage("Código de verificación es requerido"));
            }

            if (!dto.getNewPassword().equals(dto.getConfirmNewPassword())) {
                log.error("Error: No coinciden las contraseñas");
                return ResponseEntity.badRequest().body(new ApiMessage("No coinciden las contraseñas"));
            }

            String message = authService.changePasswordWithVerification(dto.getEmail(), dto.getCode(),
                    dto.getNewPassword());
            log.info("Contraseña actualizada correctamente");
            return ResponseEntity.ok(new ApiMessage(message));
        } catch (RuntimeException e) {
            log.error("Error en el cambio de contraseña: " + e.getMessage());
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
                return ResponseEntity.ok(new ApiMessage("Cierre de sesión exitoso"));
            }
            return ResponseEntity.badRequest().body(new ApiMessage("Token no proporcionado"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }

    @GetMapping("/check-auth")
    public ResponseEntity<String> checkAuth() {
        return ResponseEntity.ok().body("autenticado");
    }

    @GetMapping("/user/details")
    public Object getAuthenticatedUser() {
        try{
            SlaveUser user = userService.getUserDetails();
            return ResponseEntity.ok(user);
        }catch (Exception e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
        }
    }
}