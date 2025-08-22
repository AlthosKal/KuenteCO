package org.kuenteco.backend.controller.profile;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import java.io.IOException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.auth.LoginDTO;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.dto.profile.ChangePasswordDTO;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.image.ImageService;
import org.kuenteco.backend.service.profile.ProfileService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * Controlador para la gestión de perfiles de usuario.
 *
 * <p>Proporciona endpoints para: - Obtener perfiles - Autenticación de perfiles - Registro y
 * actualización de perfiles - Gestión de imágenes de perfil - Cambio de contraseñas
 */
@Slf4j
@RestController
@RequestMapping("/v1/profile")
@AllArgsConstructor
public class ProfileController implements ProfileResource {
    private final ProfileService profileService;
    private final ImageService imageService;

    @GetMapping
    public ResponseEntity<?> getAllProfiles(HttpServletRequest request) {
        Object result = profileService.getProfiles();
        return new ResponseEntity<>(
                ApiResponse.ok("Cuentas Obtenidas correctamente", result, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getProfileById(HttpServletRequest request, @PathVariable Integer id) {
        Object result = profileService.getProfileById(id);
        return new ResponseEntity<>(
                ApiResponse.ok("Cuentas Obtenidas correctamente", result, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/details")
    public ResponseEntity<?> getAuthenticatedProfile(HttpServletRequest request) {
        ProfileDetailDTO dto = profileService.getProfileDetails();
        return new ResponseEntity<>(
                ApiResponse.ok("Perfil Autenticado", dto, request.getRequestURI()), HttpStatus.OK);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @Valid @RequestBody LoginDTO loginDTO,
            HttpServletRequest request,
            HttpServletResponse response) {
        TokenResponseDTO dto = profileService.authenticate(loginDTO, response);
        return new ResponseEntity<>(
                ApiResponse.ok("Inicio de Sesión exitoso", dto, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/add")
    public ResponseEntity<?> register(@RequestBody NewProfileDTO dto, HttpServletRequest request) {
        profileService.registerProfile(dto);
        return new ResponseEntity<>(
                ApiResponse.ok("Cuenta registrada correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping(value = "/update", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> update(
            @RequestPart("profile") String json,
            @RequestPart(value = "image", required = false) MultipartFile file,
            HttpServletRequest request)
            throws IOException {
        profileService.updateProfile(json, file);
        return new ResponseEntity<>(
                ApiResponse.ok("Perfil actualizado correctamente", null, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping("/change-password")
    public ResponseEntity<?> changePassword(
            @Valid @RequestBody ChangePasswordDTO dto, HttpServletRequest request) {
        String message = profileService.changePassword(dto);
        log.info("Contraseña actualizada correctamente");
        return new ResponseEntity<>(
                ApiResponse.ok(message, dto, request.getRequestURI()), HttpStatus.CREATED);
    }

    // Cerrar Sesión
    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response) {
        profileService.logout(request, response);
        return new ResponseEntity<>(
                ApiResponse.ok("Cierre de Sesión exitoso", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> delete(@PathVariable Integer id, HttpServletRequest request) {
        profileService.deleteProfile(id);
        return new ResponseEntity<>(
                ApiResponse.ok("Perfil eliminado correctamente", null, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/image/add")
    public ResponseEntity<?> uploadImage(
            @RequestParam("image") MultipartFile image, HttpServletRequest request)
            throws IOException {

        ImageDTO imageDTO = imageService.saveImage(image);
        return new ResponseEntity<>(
                ApiResponse.ok("Imagen Guardada", imageDTO, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping("/image/update")
    public ResponseEntity<?> updateImage(
            @RequestParam("image") MultipartFile image, HttpServletRequest request)
            throws IOException {

        ImageDTO imageDTO = imageService.updateImage(image);
        return new ResponseEntity<>(
                ApiResponse.ok("Imagen Actualizada", imageDTO, request.getRequestURI()),
                HttpStatus.OK);
    }

    @DeleteMapping("/image/delete")
    public ResponseEntity<?> deleteImage(HttpServletResponse response) throws IOException {

        imageService.deleteImage(response);
        return ResponseEntity.noContent().build();
    }
}
