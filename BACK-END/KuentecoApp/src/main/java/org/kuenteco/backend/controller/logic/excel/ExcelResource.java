package org.kuenteco.backend.controller.logic.excel;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

@Tag(
        name = "Excel",
        description =
                "Endpoints para importación y exportación de datos financieros en formato Excel")
public interface ExcelResource {

    @Operation(
            summary = "Exportar datos financieros a Excel",
            description =
                    "Exporta todas las transacciones, presupuestos, categorías y deudas del usuario autenticado a un archivo Excel (.xlsx). El archivo incluye múltiples hojas organizadas por tipo de dato: 'Transacciones', 'Presupuestos', 'Categorías', 'Deudas'.",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Archivo Excel generado exitosamente",
                        content =
                                @Content(
                                        mediaType =
                                                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                                        schema = @Schema(type = "string", format = "binary"),
                                        examples =
                                                @ExampleObject(
                                                        name = "Archivo Excel",
                                                        description =
                                                                "Archivo binario con datos financieros organizados en múltiples hojas",
                                                        value =
                                                                "Archivo Excel descargado con nombre: finanzas.xlsx"))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Error al generar el archivo - Datos insuficientes",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Sin transacciones",
                                                    description =
                                                            "Usuario no tiene transacciones registradas",
                                                    value =
                                                            """
                            {
                                "timestamp": "2024-01-15T10:30:00Z",
                                "status": 400,
                                "error": "Bad Request",
                                "message": "No tienes Transacciones registradas",
                                "path": "/v1/excel/export"
                            }
                            """),
                                            @ExampleObject(
                                                    name = "Sin presupuestos",
                                                    description =
                                                            "Usuario no tiene presupuestos registrados",
                                                    value =
                                                            """
                            {
                                "timestamp": "2024-01-15T10:30:00Z",
                                "status": 400,
                                "error": "Bad Request",
                                "message": "No tienes presupuestos registrados",
                                "path": "/v1/excel/export"
                            }
                            """),
                                            @ExampleObject(
                                                    name = "Sin categorías",
                                                    description =
                                                            "Usuario no tiene categorías registradas",
                                                    value =
                                                            """
                            {
                                "timestamp": "2024-01-15T10:30:00Z",
                                "status": 400,
                                "error": "Bad Request",
                                "message": "No tienes Categorías registradas",
                                "path": "/v1/excel/export"
                            }
                            """),
                                            @ExampleObject(
                                                    name = "Sin deudas",
                                                    description =
                                                            "Usuario no tiene deudas registradas",
                                                    value =
                                                            """
                            {
                                "timestamp": "2024-01-15T10:30:00Z",
                                "status": 400,
                                "error": "Bad Request",
                                "message": "No tienes Deudas registradas",
                                "path": "/v1/excel/export"
                            }
                            """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "No autorizado - Token JWT inválido o expirado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Token inválido",
                                                        value =
                                                                """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 401,
                            "error": "Unauthorized",
                            "message": "JWT token is expired",
                            "path": "/v1/excel/export"
                        }
                        """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Usuario no encontrado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Usuario no encontrado",
                                                        value =
                                                                """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 404,
                            "error": "Not Found",
                            "message": "Usuario no encontrado",
                            "path": "/v1/excel/export"
                        }
                        """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Error interno",
                                                        value =
                                                                """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 500,
                            "error": "Internal Server Error",
                            "message": "Error al exportar archivo de Excel",
                            "path": "/v1/excel/export"
                        }
                        """)))
            },
            security = {
                @io.swagger.v3.oas.annotations.security.SecurityRequirement(
                        name = "Bearer Authentication")
            })
    void exportExcel(@Parameter(hidden = true) HttpServletResponse response);

    @Operation(
            summary = "Importar datos financieros desde Excel",
            description =
                    """
            Importa transacciones, presupuestos, categorías y deudas desde un archivo Excel (.xlsx).

            **Estructura requerida del archivo:**
            - **Hoja 'Transacciones':** Columnas: Nombre, Monto, Fecha (dd/MM/yyyy), Descripción, Tipo
            - **Hoja 'Presupuestos':** Columnas: Nombre, Total, Restante
            - **Hoja 'Categorías':** Columnas: Nombre, Presupuesto Asignado, Estado, Fecha de Registro (dd/MM/yyyy)
            - **Hoja 'Deudas':** Columnas: Nombre, Total, Pendiente, Fecha de Inicio (dd/MM/yyyy), Fecha de Expiración (dd/MM/yyyy), Estado

            **Para usuarios empresariales:**
            - La hoja 'Transacciones' debe incluir una columna adicional 'Perfil Asociado' como primera columna

            **Notas importantes:**
            - El usuario debe tener datos previos registrados para poder importar
            - Las filas con errores serán omitidas y registradas en los logs
            - El formato de fecha debe ser dd/MM/yyyy
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Datos importados exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Importación exitosa",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 200,
                        "success": true,
                        "message": "Datos importados correctamente",
                        "data": null,
                        "path": "/v1/excel/import"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description =
                                "Error en el archivo, formato incorrecto o datos insuficientes",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples = {
                                            @ExampleObject(
                                                    name = "Archivo no proporcionado",
                                                    description =
                                                            "No se envió archivo o está vacío",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 400,
                            "error": "Bad Request",
                            "message": "Archivo no proporcionado o vacío",
                            "path": "/v1/excel/import"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Hoja no encontrada",
                                                    description =
                                                            "Falta una hoja requerida en el archivo Excel",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 400,
                            "error": "Bad Request",
                            "message": "Hoja 'Transacciones' no encontrada",
                            "path": "/v1/excel/import"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Sin datos existentes",
                                                    description =
                                                            "El usuario no tiene datos previos para validar la importación",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 400,
                            "error": "Bad Request",
                            "message": "No tienes Transacciones registradas",
                            "path": "/v1/excel/import"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Perfil no autorizado",
                                                    description =
                                                            "Intento de importar datos de un perfil que no pertenece al usuario",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 400,
                            "error": "Bad Request",
                            "message": "El perfil 'ejemplo@email.com' no pertenece a tu cuenta.",
                            "path": "/v1/excel/import"
                        }
                        """)
                                        })),
                @ApiResponse(
                        responseCode = "401",
                        description = "No autorizado - Token JWT inválido o expirado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Token inválido",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 401,
                        "error": "Unauthorized",
                        "message": "JWT token is expired",
                        "path": "/v1/excel/import"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Usuario no encontrado",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Usuario no encontrado",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 404,
                        "error": "Not Found",
                        "message": "Usuario no encontrado",
                        "path": "/v1/excel/import"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "413",
                        description = "Archivo demasiado grande",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Archivo muy grande",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 413,
                        "error": "Payload Too Large",
                        "message": "Maximum upload size exceeded",
                        "path": "/v1/excel/import"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "415",
                        description =
                                "Tipo de archivo no soportado - Solo se aceptan archivos .xlsx",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Formato no válido",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 415,
                        "error": "Unsupported Media Type",
                        "message": "Only .xlsx files are supported",
                        "path": "/v1/excel/import"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor durante el procesamiento",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                org.kuenteco.backend.exception
                                                                        .ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Error interno",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 500,
                        "error": "Internal Server Error",
                        "message": "Error al importar archivo Excel: java.io.IOException",
                        "path": "/v1/excel/import"
                    }
                    """)))
            })
    @Parameter(
            name = "file",
            description =
                    """
            Archivo Excel (.xlsx) con los datos financieros a importar.

            **Hojas requeridas:**
            - **Transacciones**: Nombre, Monto, Fecha, Descripción, Tipo [+ Perfil Asociado para usuarios empresariales]
            - **Presupuestos**: Nombre, Total, Restante
            - **Categorías**: Nombre, Presupuesto Asignado, Estado, Fecha de Registro
            - **Deudas**: Nombre, Total, Pendiente, Fecha de Inicio, Fecha de Expiración, Estado

            **Formato de fechas:** dd/MM/yyyy
            **Tamaño máximo:** Consultar configuración del servidor
            """,
            required = true,
            content = @Content(mediaType = "multipart/form-data"),
            in = ParameterIn.DEFAULT)
    ResponseEntity<?> importExcel(@Parameter(hidden = true) HttpServletRequest request);
}
