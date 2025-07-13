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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Authentication", description = "API de autenticación y gestión de usuarios")
public interface AuthResource {

    @Operation(
            description =
                    "Autentica al usuario utilizando nombre/email y contraseña, devolviendo un token JWT",
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
                                                        value =
                                                                """
                        {
                          "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                          "role": "ROLE_USER"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Credenciales inválidas o errores de validación",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Credenciales inválidas"
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
                                  "password": "contraseña123"
                                }
                            """),
                                                @ExampleObject(
                                                        name = "Login con nombre de usuario",
                                                        value =
                                                                """
                                {
                                  "nameOrEmail": "usuario123",
                                  "password": "contraseña123"
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
            description = "Invalida el token JWT actual del usuario",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
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
                          "message": "Cierre de sesión exitoso"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
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
                          "message": "Token no proporcionado"
                        }
                    """)))
            })
    ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response);

    @Operation(
            description = "Elimina un usuario del sistema por su ID",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Usuario eliminado correctamente"),
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
                          "message": "Usuario no encontrado"
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor")
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID del usuario a eliminar",
                        required = true,
                        schema =
                                @Schema(
                                        type = "string",
                                        example = "123e4567-e89b-12d3-a456-426614174000"))
            })
    ResponseEntity<?> delete(@PathVariable String id) throws IOException;

    @Operation(
            description = "Carga una nueva imagen de perfil para el usuario autenticado",
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
                          "id": 1,
                          "name": "profile_1234.jpg",
                          "type": "image/jpeg",
                          "url": "/api/images/profile_1234.jpg"
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
            description = "Recupera los datos del usuario actualmente autenticado",
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
                                                        value =
                                                                """
                        {
                          "name": "usuario123",
                          "email": "usuario@example.com",
                          "role": {
                            "name": "USER"
                          },
                          "version": 1,
                          "masterImage": {
                            "id": 1,
                            "name": "profile_1234.jpg",
                            "type": "image/jpeg",
                            "url": "/api/images/profile_1234.jpg"
                          }
                        }
                    """))),
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "400",
                        description = "Error al obtener datos del usuario",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                """
                        {
                          "message": "Usuario no autenticado"
                        }
                    """)))
            })
    ResponseEntity<?> getAuthenticatedUser(HttpServletRequest request);
}
