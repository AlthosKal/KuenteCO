package org.kuenteco.backend.controller.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import java.io.IOException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.auth.AuthService;
import org.kuenteco.backend.service.auth.SendgridService;
import org.kuenteco.backend.service.auth.UserService;
import org.kuenteco.backend.service.image.auth.UserImageService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@RestController
@RequestMapping("/v1/auth")
@AllArgsConstructor
public class AuthController implements AuthResource {
    private final UserService userService;
    private final AuthService authService;
    private final UserImageService imageService;
    private final SendgridService sendgridService;

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @Valid @RequestBody LoginUserDTO loginUserDTO,
            HttpServletRequest request,
            HttpServletResponse response) {
        TokenResponseDTO dto = authService.authenticate(loginUserDTO, response);
        return ResponseEntity.ok(
                ApiResponse.ok("Inicio de Sesión exitoso", dto, request.getRequestURI()));
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(
            @Valid @RequestBody NewUserDTO newUserDTO, HttpServletRequest request) {
        authService.registerUser(newUserDTO);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.ok(
                                "Registro exitoso. Codigo de verificación enviado al correo",
                                newUserDTO,
                                request.getRequestURI()));
    }

    @PostMapping("/send-verification-code")
    public ResponseEntity<?> sendVerificationCode(
            @Valid @RequestBody SendVerificationCodeDTO dto,
            @RequestParam(defaultValue = "false") boolean isRegistration,
            HttpServletRequest request) {

        sendgridService.sendVerificationEmail(dto, isRegistration);
        return ResponseEntity.ok(
                ApiResponse.ok("Código de verificación enviado", dto, request.getRequestURI()));
    }

    @PostMapping("/validate-verification-code")
    public ResponseEntity<?> validateVerificationCode(
            @Valid @RequestBody ValidateVerificationCodeDTO dto, HttpServletRequest request) {
        boolean isValid = sendgridService.validateVerificationCode(dto);
        String message =
                isValid ? "Código de Verificación valido" : "Código de Verificación Invalido";
        return ResponseEntity.badRequest()
                .body(ApiResponse.ok(message, dto, request.getRequestURI()));
    }

    @PostMapping("/activate-account")
    public ResponseEntity<?> activateAccount(
            @Valid @RequestBody ValidateVerificationCodeDTO dto, HttpServletRequest request) {
        // 1. Validar el código
        if (!sendgridService.validateVerificationCode(dto)) {
            return ResponseEntity.badRequest()
                    .body(
                            ApiResponse.ok(
                                    "Código de verificación valido", dto, request.getRequestURI()));
        }
        // 2. Activar la cuenta
        authService.activateUser(dto.getEmail());
        return ResponseEntity.ok(
                ApiResponse.ok(
                        "Cuenta activada correctamente", dto.getEmail(), request.getRequestURI()));
    }

    @PutMapping("/change-password")
    public ResponseEntity<?> changePassword(
            @Valid @RequestBody ChangePasswordDTO dto, HttpServletRequest request) {
        if (dto.getCode() == null || dto.getCode().trim().isEmpty()) {
            log.error("Error: Código de verificación vació");
            return ResponseEntity.badRequest()
                    .body(
                            ApiResponse.error(
                                    "Código de verificación es requerido",
                                    request.getRequestURI()));
        }
        String message = authService.changePasswordWithVerification(dto);
        log.info("Contraseña actualizada correctamente");
        return ResponseEntity.ok(ApiResponse.ok(message, dto, request.getRequestURI()));
    }

    // Cerrar Sesión
    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response) {
        authService.logout(request, response);
        return ResponseEntity.badRequest()
                .body(ApiResponse.ok("Cierre de Sesión exitoso", null, request.getRequestURI()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable String id) throws IOException {
        userService.deteleUser(new DeleteUserDTO(id));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/user/image/add")
    public ResponseEntity<?> uploadUserImage(
            @RequestParam("image") MultipartFile image,
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        ImageDTO imageDTO = imageService.saveImage(image, request, response);
        return new ResponseEntity<>(
                ApiResponse.ok("Imagen Guardada", imageDTO, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PutMapping("/user/image/update")
    public ResponseEntity<?> updateUserImage(
            @RequestParam("image") MultipartFile image,
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        ImageDTO imageDTO = imageService.updateImage(image, request, response);
        return new ResponseEntity<>(
                ApiResponse.ok("Imagen Actualizada", imageDTO, request.getRequestURI()),
                HttpStatus.OK);
    }

    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteUserImage(
            HttpServletRequest request, HttpServletResponse response) throws IOException {

        imageService.deleteImage(request, response);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/user/details")
    public ResponseEntity<?> getAuthenticatedUser(HttpServletRequest request) {
        UserDetailDTO dto = userService.getUserDetailsDTO();
        return ResponseEntity.ok(
                ApiResponse.ok("Usuario Autenticado", dto, request.getRequestURI()));
    }
}
