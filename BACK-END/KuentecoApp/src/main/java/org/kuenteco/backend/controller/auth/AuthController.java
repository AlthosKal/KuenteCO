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
import org.kuenteco.backend.service.user.SendgridService;
import org.kuenteco.backend.service.user.UserService;
import org.kuenteco.backend.service.image.ImageService;
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
    private final ImageService imageService;
    private final SendgridService sendgridService;

    @GetMapping("/user/details")
    public ResponseEntity<?> getAuthenticatedUser(HttpServletRequest request) {
        UserDetailDTO dto = userService.getUserDetails();
        return new ResponseEntity<>(
                ApiResponse.ok("Usuario Autenticado", dto, request.getRequestURI()), HttpStatus.OK);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @Valid @RequestBody LoginDTO loginUserDTO,
            HttpServletRequest request,
            HttpServletResponse response) {
        TokenResponseDTO dto = authService.authenticate(loginUserDTO, response);
        return new ResponseEntity<>(
                ApiResponse.ok("Inicio de Sesión exitoso", dto, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(
            @Valid @RequestBody NewUserDTO newUserDTO, HttpServletRequest request) {
        authService.addUser(newUserDTO);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Registro exitoso. Código de verificación enviado al correo",
                        newUserDTO,
                        request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/send-verification-code")
    public ResponseEntity<?> sendVerificationCode(
            @Valid @RequestBody SendVerificationCodeDTO dto,
            @RequestParam(defaultValue = "false") boolean isRegistration,
            HttpServletRequest request) {

        sendgridService.sendVerificationEmail(dto, isRegistration);
        return new ResponseEntity<>(
                ApiResponse.ok("Código de verificación enviado", dto, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/validate-verification-code")
    public ResponseEntity<?> validateVerificationCode(
            @Valid @RequestBody ValidateVerificationCodeDTO dto, HttpServletRequest request) {
        boolean isValid = sendgridService.validateVerificationCode(dto);
        if (!isValid) {
            return new ResponseEntity<>(
                    ApiResponse.error("Código de Verificación Invalido", request.getRequestURI()),
                    HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>(
                ApiResponse.ok("Código de Verificación valido", dto, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/activate-user")
    public ResponseEntity<?> activateUser(
            @Valid @RequestBody ValidateVerificationCodeDTO dto, HttpServletRequest request) {

        boolean isValid = sendgridService.validateVerificationCode(dto);
        // 1. Validar el código
        if (!isValid) {
            return new ResponseEntity<>(
                    ApiResponse.error("Código de Verificación Invalido", request.getRequestURI()),
                    HttpStatus.BAD_REQUEST);
        }
        // 2. Activar la cuenta
        authService.activateUser(dto.getEmail());
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Cuenta activada correctamente", dto.getEmail(), request.getRequestURI()),
                HttpStatus.OK);
    }

    @PatchMapping("/change-password")
    public ResponseEntity<?> changePassword(
            @Valid @RequestBody ChangePasswordDTO dto, HttpServletRequest request) {
        String message = authService.changePasswordWithVerification(dto);
        log.info("Contraseña actualizada correctamente");
        return new ResponseEntity<>(
                ApiResponse.ok(message, dto, request.getRequestURI()), HttpStatus.CREATED);
    }

    // Cerrar Sesión
    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response) {
        authService.logout(request, response);
        return new ResponseEntity<>(
                ApiResponse.ok("Cierre de Sesión exitoso", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable String id) throws IOException {
        userService.deleteUser(new DeleteUserDTO(id));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/user/image/add")
    public ResponseEntity<?> uploadImage(
            @RequestParam("image") MultipartFile image, HttpServletRequest request)
            throws IOException {

        ImageDTO imageDTO = imageService.saveImage(image);
        return new ResponseEntity<>(
                ApiResponse.ok("Imagen Guardada", imageDTO, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping("/user/image/update")
    public ResponseEntity<?> updateImage(
            @RequestParam("image") MultipartFile image, HttpServletRequest request)
            throws IOException {

        ImageDTO imageDTO = imageService.updateImage(image);
        return new ResponseEntity<>(
                ApiResponse.ok("Imagen Actualizada", imageDTO, request.getRequestURI()),
                HttpStatus.OK);
    }

    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteImage(HttpServletResponse response) throws IOException {

        imageService.deleteImage(response);
        return ResponseEntity.noContent().build();
    }
}
