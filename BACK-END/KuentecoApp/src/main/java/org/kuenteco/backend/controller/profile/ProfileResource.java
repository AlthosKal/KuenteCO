package org.kuenteco.backend.controller.profile;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import java.io.IOException;
import org.kuenteco.backend.dto.auth.LoginDTO;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.dto.profile.ChangePasswordDTO;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Profile", description = "API para la gestión de perfiles de usuario")
public interface ProfileResource {

    @Operation(
            summary = "Obtener todos los perfiles",
            description = "Obtiene una lista de todos los perfiles del sistema",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "List of profiles",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ProfileDetailDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "[ { \"id\": 1, \"username\": \"JohnDoe\" } ]")))
            })
    @GetMapping
    ResponseEntity<?> getAllProfiles(HttpServletRequest request);

    @Operation(
            summary = "Obtener perfil autenticado",
            description = "Recupera los detalles del perfil actualmente autenticado",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Perfil autenticado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ProfileDetailDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"id\": 1, \"username\": \"JohnDoe\" }")))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token JWT para autenticación",
                        required = true)
            })
    @GetMapping("/details")
    ResponseEntity<?> getAuthenticatedProfile(HttpServletRequest request);

    @Operation(
            summary = "Inicio de sesión de perfil",
            description = "Autentica al usuario y retorna un token JWT",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Inicio de sesión exitoso",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = TokenResponseDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value = "{ \"token\": \"jwt-token\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = LoginDTO.class))))
    @PostMapping("/login")
    ResponseEntity<?> login(
            @Valid @RequestBody LoginDTO loginDTO,
            HttpServletRequest request,
            HttpServletResponse response);

    @Operation(
            summary = "Registrar nuevo perfil",
            description = "Registra un nuevo perfil en el sistema",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "201",
                        description = "Perfil registrado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Perfil registrado correctamente\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(implementation = NewProfileDTO.class))))
    @PostMapping("/add")
    ResponseEntity<?> register(@RequestBody NewProfileDTO dto, HttpServletRequest request);

    @Operation(
            summary = "Actualizar perfil",
            description = "Actualiza un perfil existente",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Perfil actualizado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Perfil actualizado correctamente\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation =
                                                                    UpdateProfileDTO.class))))
    @PatchMapping(value = "/update", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    ResponseEntity<?> update(
            @RequestPart("profile") UpdateProfileDTO dto,
            @RequestPart(value = "image", required = false) MultipartFile file,
            HttpServletRequest request)
            throws IOException;

    @Operation(
            summary = "Cambiar contraseña del perfil",
            description = "Actualiza la contraseña de un perfil mediante código de verificación",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Contraseña actualizada",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Contraseña actualizada correctamente\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation =
                                                                    ChangePasswordDTO.class))))
    @PatchMapping("/change-password")
    ResponseEntity<?> changePassword(
            @Valid @RequestBody ChangePasswordDTO dto, HttpServletRequest request);

    @Operation(
            summary = "Cerrar sesión de perfil",
            description = "Invalida el token JWT del usuario actual",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Sesión cerrada",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Sesión cerrada correctamente\" }")))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token JWT para autenticación",
                        required = true)
            })
    @PostMapping("/logout")
    ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response);

    @Operation(
            summary = "Eliminar perfil",
            description = "Elimina un perfil por su ID",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Perfil eliminado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Perfil eliminado correctamente\" }")))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID del perfil a eliminar",
                        required = true)
            })
    @DeleteMapping("/{id}")
    ResponseEntity<?> delete(@PathVariable Integer id, HttpServletRequest request);

    @Operation(
            summary = "Subir imagen de perfil",
            description = "Guarda una nueva imagen de perfil",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "201",
                        description = "Imagen subida",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ImageDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"name\": \"image.jpg\", \"url\": \"/images/image.jpg\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.MULTIPART_FORM_DATA_VALUE,
                                            schema = @Schema(type = "string", format = "binary"))))
    @PostMapping("/image/add")
    ResponseEntity<?> uploadImage(
            @RequestParam("image") MultipartFile image, HttpServletRequest request)
            throws IOException;

    @Operation(
            summary = "Actualizar imagen de perfil",
            description = "Actualiza la imagen de perfil existente",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Imagen actualizada",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ImageDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"name\": \"image_updated.jpg\", \"url\": \"/images/image_updated.jpg\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.MULTIPART_FORM_DATA_VALUE,
                                            schema = @Schema(type = "string", format = "binary"))))
    @PatchMapping("/image/update")
    ResponseEntity<?> updateImage(
            @RequestParam("image") MultipartFile image, HttpServletRequest request)
            throws IOException;

    @Operation(
            summary = "Eliminar imagen de perfil",
            description = "Elimina la imagen de perfil del usuario",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Imagen eliminada")
            })
    @DeleteMapping("/delete")
    ResponseEntity<?> deleteImage(HttpServletResponse response) throws IOException;
}
