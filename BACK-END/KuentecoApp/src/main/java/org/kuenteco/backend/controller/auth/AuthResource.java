package org.kuenteco.backend.controller.auth;

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
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Authentication", description = "API de autenticación y gestión de usuarios")
public interface AuthResource {

    @Operation(
            summary = "Autenticación de usuario",
            description =
                    "Autentica al usuario utilizando nombre/email y contraseña, devolviendo un token JWT válido",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Autenticación exitosa",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = TokenResponseDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Login exitoso",
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Inicio de Sesión exitoso",
                          "data": {
                            "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c3VhcmlvMTIzIiwiaWF0IjoxNjQwOTk1MjAwLCJleHAiOjE2NDEwODE2MDB9.signature",
                            "role": "ROLE_USER"
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/login"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Credenciales inválidas o errores de validación",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Credenciales incorrectas",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "Credenciales inválidas",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/login"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Usuario no activado",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "Cuenta no activada. Por favor, verifica tu email",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/login"
                        }
                    """),
                                            @ExampleObject(
                                                    name = "Campos requeridos",
                                                    value =
                                                            """
                        {
                          "success": false,
                          "message": "nameOrEmail y password son requeridos",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/login"
                        }
                    """)
                                        })),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "429",
                        description = "Demasiados intentos de inicio de sesión",
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
                          "message": "Demasiados intentos de inicio de sesión. Intenta de nuevo en 15 minutos",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/login"
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
                          "path": "/v1/auth/login"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = LoginDTO.class),
                                            examples = {
                                                @ExampleObject(
                                                        name = "Login con email",
                                                        value =
                                                                """
                                {
                                  "nameOrEmail": "usuario@example.com",
                                  "password": "MiPassword123@"
                                }
                            """),
                                                @ExampleObject(
                                                        name = "Login con nombre de usuario",
                                                        value =
                                                                """
                                {
                                  "nameOrEmail": "usuario123",
                                  "password": "MiPassword123@"
                                }
                            """)
                                            })))
    ResponseEntity<?> login(
            @Valid @RequestBody LoginDTO loginUserDTO,
            HttpServletRequest request,
            HttpServletResponse response);

    @Operation(
            description =
                    "Registra un nuevo usuario en el sistema y envía un código de verificación al correo",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "201",
                        description = "Usuario registrado exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Registro exitoso. Codigo de verificación enviado al correo"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Datos inválidos o usuario ya existente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "El email ya se encuentra registrado"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = NewUserDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            value =
                                                                    """
                        {
                          "username": "usuario123",
                          "email": "usuario@example.com",
                          "password": "MiPassword123@",
                          "type": "PERSONAL"
                        }
                    """))))
    ResponseEntity<?> register(
            @Valid @RequestBody NewUserDTO newUserDTO, HttpServletRequest request);

    @Operation(
            description = "Envía un código de verificación al correo electrónico proporcionado",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Código enviado exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Código de verificación enviado"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Email inválido o no encontrado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Email no registrado en el sistema"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno al enviar el código",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Error enviando código de verificación"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation =
                                                                    SendVerificationCodeDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            value =
                                                                    """
                        {
                          "email": "usuario@example.com"
                        }
                    """))),
            parameters = {
                @Parameter(
                        in = ParameterIn.QUERY,
                        name = "isRegistration",
                        description =
                                "Indica si el código es para registro (true) o recuperación de contraseña (false)",
                        schema = @Schema(type = "boolean", defaultValue = "false"))
            })
    ResponseEntity<?> sendVerificationCode(
            @Valid @RequestBody SendVerificationCodeDTO dto,
            @RequestParam(defaultValue = "false") boolean isRegistration,
            HttpServletRequest request);

    @Operation(
            description = "Verifica si el código proporcionado para un email es válido",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Código válido",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Código de verificación valido"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Código inválido o expirado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Código de verificación invalido"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation =
                                                                    ValidateVerificationCodeDTO
                                                                            .class),
                                            examples =
                                                    @ExampleObject(
                                                            value =
                                                                    """
                        {
                          "email": "usuario@example.com",
                          "code": "123456"
                        }
                    """))))
    ResponseEntity<?> validateVerificationCode(
            @Valid @RequestBody ValidateVerificationCodeDTO dto, HttpServletRequest request);

    @Operation(
            description = "Activa la cuenta de un usuario mediante verificación de código",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Cuenta activada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Cuenta activada correctamente"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Código inválido o cuenta ya activada",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Código de verificación inválido"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation =
                                                                    ValidateVerificationCodeDTO
                                                                            .class),
                                            examples =
                                                    @ExampleObject(
                                                            value =
                                                                    """
                        {
                          "email": "usuario@example.com",
                          "code": "123456"
                        }
                    """))))
    ResponseEntity<?> activateUser(
            @Valid @RequestBody ValidateVerificationCodeDTO dto, HttpServletRequest request);

    @Operation(
            description = "Actualiza la contraseña de un usuario con verificación por código",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Contraseña actualizada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Contraseña actualizada correctamente"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Código inválido o contraseñas no coinciden",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "No coinciden las contraseñas"
                        }
                    """)))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation =
                                                                    ChangePasswordDTO.class),
                                            examples =
                                                    @ExampleObject(
                                                            value =
                                                                    """
                        {
                          "email": "usuario@example.com",
                          "code": "123456",
                          "newPassword": "nuevaContraseña123",
                          "confirmNewPassword": "nuevaContraseña123"
                        }
                    """))))
    ResponseEntity<?> changePassword(
            @Valid @RequestBody ChangePasswordDTO dto, HttpServletRequest request);

    @Operation(
            summary = "Cerrar sesión de usuario",
            description = "Invalida el token JWT actual del usuario y cierra la sesión activa",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Sesión cerrada correctamente",
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
                          "message": "Cierre de sesión exitoso",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/logout"
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
                          "path": "/v1/auth/logout"
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
                          "path": "/v1/auth/logout"
                        }
                    """)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response);

    @Operation(
            summary = "Eliminar cuenta de usuario",
            description =
                    "Elimina permanentemente la cuenta del usuario autenticado y todos sus datos asociados",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Usuario eliminado correctamente"),
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
                          "path": "/v1/auth/user/delete"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "404",
                        description = "Usuario no encontrado",
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
                          "message": "Usuario no encontrado",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/user/delete"
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
                          "path": "/v1/auth/user/delete"
                        }
                    """)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    ResponseEntity<?> delete() throws IOException;

    @Operation(
            summary = "Subir imagen de perfil",
            description =
                    "Carga una nueva imagen de perfil para el usuario autenticado. Formatos soportados: JPG, PNG, GIF. Tamaño máximo: 5MB",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "201",
                        description = "Imagen subida correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ImageDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "success": true,
                          "message": "Imagen guardada",
                          "data": {
                            "id": 1,
                            "name": "profile_1234.jpg",
                            "type": "image/jpeg",
                            "url": "https://res.cloudinary.com/kuenteco/image/upload/v1234567890/profile_1234.jpg"
                          },
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/user/image/add"
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
                          "path": "/v1/auth/user/image/add"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Archivo no válido o formato incorrecto",
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
                          "message": "Formato de imagen no soportado. Use JPG, PNG o GIF",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/user/image/add"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "413",
                        description = "Archivo muy grande",
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
                          "message": "El archivo excede el tamaño máximo permitido de 5MB",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/user/image/add"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno al procesar la imagen",
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
                          "message": "Error interno al procesar la imagen",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/user/image/add"
                        }
                    """)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    @PostMapping("/user/image/add")
    ResponseEntity<?> uploadImage(
            @RequestParam("image") MultipartFile image, HttpServletRequest request)
            throws IOException;

    @Operation(
            description = "Actualiza la imagen de perfil existente del usuario autenticado",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Imagen actualizada correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ImageDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "id": 1,
                          "name": "profile_1234_updated.jpg",
                          "type": "image/jpeg",
                          "url": "/api/images/profile_1234_updated.jpg"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error al procesar la imagen")
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token de autorización (Bearer)",
                        required = true,
                        schema =
                                @Schema(
                                        type = "string",
                                        example = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."))
            })
    ResponseEntity<?> updateImage(
            @RequestParam("image") MultipartFile image, HttpServletRequest request)
            throws IOException;

    @Operation(
            description = "Elimina la imagen de perfil del usuario autenticado",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Imagen eliminada correctamente"),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error al eliminar la imagen")
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token de autorización (Bearer)",
                        required = true,
                        schema =
                                @Schema(
                                        type = "string",
                                        example = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."))
            })
    ResponseEntity<?> deleteImage(HttpServletResponse response) throws IOException;

    @Operation(
            summary = "Obtener detalles del usuario autenticado",
            description =
                    "Recupera los datos completos del usuario actualmente autenticado incluyendo información de perfil, suscripción e imagen",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Datos del usuario recuperados correctamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = UserDetailDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Usuario con imagen",
                                                        value =
                                                                """
                        {
                          "version": 1,
                          "image": {
                            "id": 1,
                            "name": "profile_1234.jpg",
                            "type": "image/jpeg",
                            "url": "https://res.cloudinary.com/kuenteco/image/upload/v1234567890/profile_1234.jpg"
                          },
                          "username": "usuario123",
                          "email": "usuario@example.com",
                          "userType": "PERSONAL",
                          "subscriptionType": "FREE",
                          "state": "ACTIVE"
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
                          "path": "/v1/auth/user/details"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "403",
                        description = "Token expirado o usuario no autorizado",
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
                          "message": "Token expirado o acceso denegado",
                          "timestamp": "2024-01-15T10:30:00Z",
                          "path": "/v1/auth/user/details"
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
                          "path": "/v1/auth/user/details"
                        }
                    """)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    ResponseEntity<?> getAuthenticatedUser(@Parameter(hidden = true) HttpServletRequest request);
}
