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
                        description = "Lista de perfiles obtenida correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ProfileDetailDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Cuentas obtenidas correctamente",
                          "data": [
                            {
                              "id": 1,
                              "username": "JohnDoe",
                              "email": "john@example.com",
                              "image": {
                                "id": 1,
                                "name": "profile_john.jpg",
                                "type": "image/jpeg",
                                "url": "https://res.cloudinary.com/kuenteco/image/upload/v1234567890/profile_john.jpg"
                              }
                            }
                          ],
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile"
                        }
                    """)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping
    ResponseEntity<?> getAllProfiles(HttpServletRequest request);

    @Operation(
            summary = "Obtener perfil por ID",
            description = "Recupera un perfil específico por su identificador único",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Perfil encontrado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ProfileDetailDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Cuenta obtenida correctamente",
                          "data": {
                            "id": 1,
                            "username": "JohnDoe",
                            "email": "john@example.com",
                            "image": {
                              "id": 1,
                              "name": "profile_john.jpg",
                              "type": "image/jpeg",
                              "url": "https://res.cloudinary.com/kuenteco/image/upload/v1234567890/profile_john.jpg"
                            }
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/1"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/1"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "404",
                        description = "Perfil no encontrado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Perfil no encontrado con ID: 1",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/1"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/1"
                        }
                    """)))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID del perfil a consultar",
                        required = true,
                        schema = @Schema(type = "integer", example = "1"))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/{id}")
    ResponseEntity<?> getProfileById(
            @Parameter(hidden = true) HttpServletRequest request, @PathVariable Integer id);

    @Operation(
            summary = "Obtener perfil autenticado",
            description = "Recupera los detalles completos del perfil actualmente autenticado",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Perfil autenticado obtenido correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ProfileDetailDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Perfil Autenticado",
                          "data": {
                            "id": 1,
                            "username": "JohnDoe",
                            "email": "john@example.com",
                            "image": {
                              "id": 1,
                              "name": "profile_john.jpg",
                              "type": "image/jpeg",
                              "url": "https://res.cloudinary.com/kuenteco/image/upload/v1234567890/profile_john.jpg"
                            }
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/details"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/details"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/details"
                        }
                    """)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @GetMapping("/details")
    ResponseEntity<?> getAuthenticatedProfile(@Parameter(hidden = true) HttpServletRequest request);

    @Operation(
            summary = "Inicio de sesión de perfil",
            description =
                    "Autentica un perfil utilizando nombre/email y contraseña, retorna un token JWT para sesión de perfil",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Inicio de sesión de perfil exitoso",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = TokenResponseDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Inicio de Sesión exitoso",
                          "data": {
                            "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJwcm9maWxlMSIsImlhdCI6MTY0MDk5NTIwMCwiZXhwIjoxNjQxMDgxNjAwfQ.signature",
                            "role": "ROLE_PROFILE"
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/login"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Credenciales inválidas o datos incorrectos",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Credenciales de perfil inválidas",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/login"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/login"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = LoginDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Login de perfil",
                                                            value =
                                                                    """
                        {
                          "nameOrEmail": "Dex",
                          "password": "password123"
                        }
                    """))))
    @PostMapping("/login")
    ResponseEntity<?> login(
            @Valid @RequestBody LoginDTO loginDTO,
            @Parameter(hidden = true) HttpServletRequest request,
            @Parameter(hidden = true) HttpServletResponse response);

    @Operation(
            summary = "Registrar nuevo perfil",
            description = "Registra un nuevo perfil en el sistema con validación de datos",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "201",
                        description = "Perfil registrado correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Cuenta registrada correctamente",
                          "data": {
                            "username": "Dex",
                            "email": "agudelocastanoyeferson270@gmail.com"
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/add"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Datos de validación incorrectos o perfil existente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Email ya registrado",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El email ya se encuentra registrado en otro perfil",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/add"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Campos requeridos",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "El nombre de usuario es requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/add"
                        }
                    """)
                                        })),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/add"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewProfileDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            name = "Nuevo perfil",
                                                            value =
                                                                    """
                        {
                          "username": "Dex",
                          "email": "agudelocastanoyeferson270@gmail.com",
                          "password": "password123"
                        }
                    """))))
    @PostMapping("/add")
    ResponseEntity<?> register(
            @RequestBody NewProfileDTO dto, @Parameter(hidden = true) HttpServletRequest request);

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
            @RequestPart("profile") String json,
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
            description = "Invalida el token JWT del perfil actual y cierra la sesión activa",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Sesión de perfil cerrada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Cierre de Sesión exitoso",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/logout"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "401",
                        description = "Token no proporcionado o inválido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Token de autenticación requerido",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/logout"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": false,
                          "message": "Error interno del servidor",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/profile/logout"
                        }
                    """)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/logout")
    ResponseEntity<?> logout(
            @Parameter(hidden = true) HttpServletRequest request,
            @Parameter(hidden = true) HttpServletResponse response);

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
    @DeleteMapping("/delete/{id}")
    ResponseEntity<?> delete(
            @PathVariable Integer id, @Parameter(hidden = true) HttpServletRequest request);

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
    @DeleteMapping("/image/delete")
    ResponseEntity<?> deleteImage(@Parameter(hidden = true) HttpServletResponse response)
            throws IOException;
}
