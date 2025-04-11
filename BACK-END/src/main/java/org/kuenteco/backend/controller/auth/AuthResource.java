package org.kuenteco.backend.controller.auth;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.auth.*;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.jwt.JwtUtil;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Authentication", description = "API de autenticación y gestión de usuarios")
public interface AuthResource {

    @Operation(description = "Autentica al usuario utilizando nombre/email y contraseña, devolviendo un token JWT", responses = {
            @ApiResponse(responseCode = "200", description = "Autenticación exitosa", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = TokenResponseDTO.class), examples = @ExampleObject(value = """
                        {
                          "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                          "role": "ROLE_USER"
                        }
                    """))),
            @ApiResponse(responseCode = "400", description = "Credenciales inválidas o errores de validación", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Credenciales inválidas"
                        }
                    """))) }, requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = LoginUserDTO.class), examples = {
                    @ExampleObject(name = "Login con email", value = """
                                {
                                  "nameOrEmail": "usuario@example.com",
                                  "password": "contraseña123"
                                }
                            """), @ExampleObject(name = "Login con nombre de usuario", value = """
                                {
                                  "nameOrEmail": "usuario123",
                                  "password": "contraseña123"
                                }
                            """) })))
    ResponseEntity<?> login(@Valid @RequestBody LoginUserDTO loginUserDTO, BindingResult bindingResult,
            HttpServletResponse response);

    @Operation(description = "Registra un nuevo usuario en el sistema y envía un código de verificación al correo", responses = {
            @ApiResponse(responseCode = "201", description = "Usuario registrado exitosamente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Registro exitoso. Codigo de verificación enviado al correo"
                        }
                    """))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos o usuario ya existente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "El email ya se encuentra registrado"
                        }
                    """))) }, requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NewUserDTO.class), examples = @ExampleObject(value = """
                        {
                          "name": "usuario123",
                          "email": "usuario@example.com",
                          "password": "contraseña123"
                        }
                    """))))
    ResponseEntity<ApiMessage> register(@Valid @RequestBody NewUserDTO newUserDTO, BindingResult bindingResult);

    @Operation(description = "Envía un código de verificación al correo electrónico proporcionado", responses = {
            @ApiResponse(responseCode = "200", description = "Código enviado exitosamente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Código de verificación enviado"
                        }
                    """))),
            @ApiResponse(responseCode = "400", description = "Email inválido o no encontrado", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Email no registrado en el sistema"
                        }
                    """))),
            @ApiResponse(responseCode = "500", description = "Error interno al enviar el código", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Error enviando código de verificación"
                        }
                    """))) }, requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = SendVerificationCodeDTO.class), examples = @ExampleObject(value = """
                        {
                          "email": "usuario@example.com"
                        }
                    """))), parameters = {
                    @Parameter(in = ParameterIn.QUERY, name = "isRegistration", description = "Indica si el código es para registro (true) o recuperación de contraseña (false)", schema = @Schema(type = "boolean", defaultValue = "false")) })
    ResponseEntity<ApiMessage> sendVerificationCode(@Valid @RequestBody SendVerificationCodeDTO sendVerificationCodeDTO,
            @RequestParam(required = false, defaultValue = "false") boolean isRegistration);

    @Operation(description = "Verifica si el código proporcionado para un email es válido", responses = {
            @ApiResponse(responseCode = "200", description = "Código válido", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Código de verificación valido"
                        }
                    """))),
            @ApiResponse(responseCode = "400", description = "Código inválido o expirado", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Código de verificación invalido"
                        }
                    """))) }, requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ValidateVerificationCodeDTO.class), examples = @ExampleObject(value = """
                        {
                          "email": "usuario@example.com",
                          "code": "123456"
                        }
                    """))))
    ResponseEntity<ApiMessage> validateVerificationCode(@Valid @RequestBody ValidateVerificationCodeDTO dto);

    @Operation(description = "Activa la cuenta de un usuario mediante verificación de código", responses = {
            @ApiResponse(responseCode = "200", description = "Cuenta activada correctamente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Cuenta activada correctamente"
                        }
                    """))),
            @ApiResponse(responseCode = "400", description = "Código inválido o cuenta ya activada", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Código de verificación inválido"
                        }
                    """))) }, requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ValidateVerificationCodeDTO.class), examples = @ExampleObject(value = """
                        {
                          "email": "usuario@example.com",
                          "code": "123456"
                        }
                    """))))
    ResponseEntity<ApiMessage> activateAccount(@Valid @RequestBody ValidateVerificationCodeDTO dto);

    @Operation(description = "Actualiza la contraseña de un usuario con verificación por código", responses = {
            @ApiResponse(responseCode = "200", description = "Contraseña actualizada correctamente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Contraseña actualizada correctamente"
                        }
                    """))),
            @ApiResponse(responseCode = "400", description = "Código inválido o contraseñas no coinciden", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "No coinciden las contraseñas"
                        }
                    """))) }, requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ChangePasswordDTO.class), examples = @ExampleObject(value = """
                        {
                          "email": "usuario@example.com",
                          "code": "123456",
                          "newPassword": "nuevaContraseña123",
                          "confirmNewPassword": "nuevaContraseña123"
                        }
                    """))))
    ResponseEntity<ApiMessage> changePassword(@Valid @RequestBody ChangePasswordDTO dto);

    @Operation(description = "Invalida el token JWT actual del usuario", responses = {
            @ApiResponse(responseCode = "200", description = "Sesión cerrada correctamente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Cierre de sesión exitoso"
                        }
                    """))),
            @ApiResponse(responseCode = "400", description = "Token no proporcionado o inválido", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Token no proporcionado"
                        }
                    """))) })
    ResponseEntity<ApiMessage> logout(HttpServletRequest request, HttpServletResponse response, JwtUtil jwtUtil);

    @Operation(description = "Carga una nueva imagen de perfil para el usuario autenticado", responses = {
            @ApiResponse(responseCode = "201", description = "Imagen subida correctamente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ImageDTO.class), examples = @ExampleObject(value = """
                        {
                          "id": 1,
                          "name": "profile_1234.jpg",
                          "type": "image/jpeg",
                          "url": "/api/images/profile_1234.jpg"
                        }
                    """))),
            @ApiResponse(responseCode = "500", description = "Error al procesar la imagen") }, parameters = {
                    @Parameter(in = ParameterIn.HEADER, name = "Authorization", description = "Token de autorización (Bearer)", required = true, schema = @Schema(type = "string", example = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")) })
    ResponseEntity<ImageDTO> uploadProfileImage(@RequestParam("image") MultipartFile image,
            @RequestHeader("Authorization") String token, HttpServletResponse response);

    @Operation(description = "Actualiza la imagen de perfil existente del usuario autenticado", responses = {
            @ApiResponse(responseCode = "200", description = "Imagen actualizada correctamente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ImageDTO.class), examples = @ExampleObject(value = """
                        {
                          "id": 1,
                          "name": "profile_1234_updated.jpg",
                          "type": "image/jpeg",
                          "url": "/api/images/profile_1234_updated.jpg"
                        }
                    """))),
            @ApiResponse(responseCode = "500", description = "Error al procesar la imagen") }, parameters = {
                    @Parameter(in = ParameterIn.HEADER, name = "Authorization", description = "Token de autorización (Bearer)", required = true, schema = @Schema(type = "string", example = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")) })
    ResponseEntity<ImageDTO> updateProfileImage(@RequestParam("image") MultipartFile image,
            @RequestHeader("Authorization") String token, HttpServletResponse response);

    @Operation(description = "Elimina la imagen de perfil del usuario autenticado", responses = {
            @ApiResponse(responseCode = "204", description = "Imagen eliminada correctamente"),
            @ApiResponse(responseCode = "500", description = "Error al eliminar la imagen") }, parameters = {
                    @Parameter(in = ParameterIn.HEADER, name = "Authorization", description = "Token de autorización (Bearer)", required = true, schema = @Schema(type = "string", example = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")) })
    ResponseEntity<Void> deleteProfileImage(@RequestHeader("Authorization") String token, HttpServletResponse response);

    @Operation(description = "Recupera los datos del usuario actualmente autenticado", responses = {
            @ApiResponse(responseCode = "200", description = "Datos del usuario recuperados correctamente", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = UserDetailDTO.class), examples = @ExampleObject(value = """
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
            @ApiResponse(responseCode = "400", description = "Error al obtener datos del usuario", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ApiMessage.class), examples = @ExampleObject(value = """
                        {
                          "message": "Usuario no autenticado"
                        }
                    """))) })
    Object getAuthenticatedUser();
}