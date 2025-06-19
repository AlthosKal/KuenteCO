package org.kuenteco.backend.controller.profile;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import java.io.IOException;
import java.util.List;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.dto.profile.LoginProfileDTO;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.image.profile.ProfileImageService;
import org.kuenteco.backend.service.profile.ProfileService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/v1/profile")
@AllArgsConstructor
public class ProfileController {

    private final ProfileService profileService;
    private final ProfileImageService imageService;

    @GetMapping
    public ResponseEntity<?> getAllProfiles(HttpServletRequest request) {
        Object dto = profileService.getProfiles();
        return ResponseEntity.status(HttpStatus.OK).body(
                ApiResponse.ok(
                        "Cuentas Obtenidas correctamente",
                        dto,
                        request.getRequestURI()));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @Valid @RequestBody LoginProfileDTO loginProfileDTO,
            HttpServletRequest request,
            HttpServletResponse response) {
        TokenResponseDTO dto = profileService.authenticate(loginProfileDTO, response);
        return ResponseEntity.ok(
                ApiResponse.ok("Inicio de Sesión exitoso", dto, request.getRequestURI()));
    }

    @PostMapping("/add")
    public ResponseEntity<?> registerProfile(
            @RequestBody NewProfileDTO dto,
            HttpServletRequest request,
            HttpServletResponse response) {
        profileService.registerProfile(dto);
        return ResponseEntity.ok(
                ApiResponse.ok("Cuenta registrada correctamente", null, request.getRequestURI()));
    }

    @PostMapping("/update")
    public ResponseEntity<?> updateProfile(
            @RequestBody UpdateProfileDTO dto,
            HttpServletRequest request,
            HttpServletResponse response) {
        profileService.updateProfile(dto);
        return ResponseEntity.ok(
                ApiResponse.ok("Cuenta actualizada correctamente", null, request.getRequestURI()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProfile(Profile profile, HttpServletRequest request) {
        profileService.deleteProfile(profile);
        return ResponseEntity.ok(
                ApiResponse.ok("Perfil eliminado correctamente", null, request.getRequestURI()));
    }

    @PostMapping("/image/add")
    public ResponseEntity<?> uploadProfileImage(
            @RequestParam("image") MultipartFile image,
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        ImageDTO imageDTO = imageService.saveImage(image, request, response);
        return new ResponseEntity<>(
                ApiResponse.ok("Imagen Guardada", imageDTO, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PutMapping("/image/update")
    public ResponseEntity<?> updateProfileImage(
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
    public ResponseEntity<?> deleteProfileImage(
            HttpServletRequest request, HttpServletResponse response) throws IOException {

        imageService.deleteImage(request, response);
        return ResponseEntity.noContent().build();
    }
}
