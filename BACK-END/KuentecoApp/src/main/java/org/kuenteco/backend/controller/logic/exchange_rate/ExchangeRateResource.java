package org.kuenteco.backend.controller.logic.exchange_rate;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyRequestDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyResponseDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ExchangeRateDTO;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(
        name = "Exchange Rates",
        description = "Endpoints para consulta de tasas de cambio y conversión de monedas")
public interface ExchangeRateResource {

    @Operation(
            summary = "Obtener todas las tasas de cambio",
            description =
                    "Recupera todas las tasas de cambio disponibles en el sistema. Si no existen tasas en la base de datos, se obtienen automáticamente desde fuentes externas y se almacenan para consultas posteriores.",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Tasas de cambio obtenidas exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        array =
                                                @ArraySchema(
                                                        schema =
                                                                @Schema(
                                                                        implementation =
                                                                                ExchangeRateDTO
                                                                                        .class)),
                                        examples =
                                                @ExampleObject(
                                                        name = "Lista de tasas de cambio",
                                                        value =
                                                                """
                        [
                            {
                                "baseCurrency": "USD",
                                "targetCurrency": "COP",
                                "rate": 4250.50,
                                "lastUpdated": "2024-01-15T10:30:00.000+00:00"
                            },
                            {
                                "baseCurrency": "EUR",
                                "targetCurrency": "COP",
                                "rate": 4650.25,
                                "lastUpdated": "2024-01-15T10:30:00.000+00:00"
                            },
                            {
                                "baseCurrency": "USD",
                                "targetCurrency": "EUR",
                                "rate": 0.92,
                                "lastUpdated": "2024-01-15T10:30:00.000+00:00"
                            }
                        ]
                        """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno al obtener las tasas de cambio",
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
                            "message": "Error al obtener las tasas de cambio desde el proveedor externo",
                            "path": "/v1/exchange-rates"
                        }
                        """))),
                @ApiResponse(
                        responseCode = "503",
                        description = "Servicio de tasas de cambio no disponible",
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
                                                        name = "Servicio no disponible",
                                                        value =
                                                                """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 503,
                            "error": "Service Unavailable",
                            "message": "El servicio de tasas de cambio no está disponible temporalmente",
                            "path": "/v1/exchange-rates"
                        }
                        """)))
            })
    ResponseEntity<List<ExchangeRateDTO>> getAllRates();

    @Operation(
            summary = "Convertir moneda",
            description =
                    """
            Convierte un monto de una moneda base a una moneda objetivo utilizando las tasas de cambio más recientes disponibles.

            **Monedas soportadas:**
            - USD (Dólar Estadounidense)
            - EUR (Euro)
            - COP (Peso Colombiano)
            - Y otras según disponibilidad en el sistema

            **Formato de monedas:** Código ISO 4217 de 3 caracteres (ej: USD, EUR, COP)
            """)
    @ApiResponses(
            value = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Conversión realizada exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                ConvertCurrencyResponseDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        name = "Conversión exitosa",
                                                        value =
                                                                """
                    {
                        "convertedAmount": 4250500.00,
                        "baseCurrency": "USD",
                        "targetCurrency": "COP",
                        "rate": 4250.50
                    }
                    """))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Datos de solicitud inválidos",
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
                                                    name = "Monto inválido",
                                                    description = "Monto fuera del rango permitido",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 400,
                            "error": "Bad Request",
                            "message": "El monto debe ser un valor monetario válido para conversión",
                            "path": "/v1/exchange-rates/convert"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Moneda inválida",
                                                    description =
                                                            "Código de moneda con formato incorrecto",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 400,
                            "error": "Bad Request",
                            "message": "La moneda base debe tener exactamente 3 caracteres (código ISO)",
                            "path": "/v1/exchange-rates/convert"
                        }
                        """),
                                            @ExampleObject(
                                                    name = "Campos requeridos",
                                                    description =
                                                            "Faltan campos obligatorios en la solicitud",
                                                    value =
                                                            """
                        {
                            "timestamp": "2024-01-15T10:30:00Z",
                            "status": 400,
                            "error": "Bad Request",
                            "message": "El monto es requerido",
                            "path": "/v1/exchange-rates/convert"
                        }
                        """)
                                        })),
                @ApiResponse(
                        responseCode = "404",
                        description = "Tasa de cambio no encontrada",
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
                                                        name = "Tasa no encontrada",
                                                        value =
                                                                """
                    {
                        "timestamp": "2024-01-15T10:30:00Z",
                        "status": 404,
                        "error": "Not Found",
                        "message": "Tasa no encontrada",
                        "path": "/v1/exchange-rates/convert"
                    }
                    """))),
                @ApiResponse(
                        responseCode = "500",
                        description = "Error interno del servidor durante la conversión",
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
                        "message": "Error interno al procesar la conversión de moneda",
                        "path": "/v1/exchange-rates/convert"
                    }
                    """)))
            })
    @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Datos para la conversión de moneda",
            required = true,
            content =
                    @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ConvertCurrencyRequestDTO.class),
                            examples = {
                                @ExampleObject(
                                        name = "USD a COP",
                                        description = "Convertir 1000 USD a Pesos Colombianos",
                                        value =
                                                """
                    {
                        "amount": 1000.00,
                        "baseCurrency": "USD",
                        "targetCurrency": "COP"
                    }
                    """),
                                @ExampleObject(
                                        name = "EUR a USD",
                                        description = "Convertir 500 EUR a Dólares",
                                        value =
                                                """
                    {
                        "amount": 500.00,
                        "baseCurrency": "EUR",
                        "targetCurrency": "USD"
                    }
                    """),
                                @ExampleObject(
                                        name = "COP a USD",
                                        description = "Convertir 1000000 COP a Dólares",
                                        value =
                                                """
                    {
                        "amount": 1000000.00,
                        "baseCurrency": "COP",
                        "targetCurrency": "USD"
                    }
                    """)
                            }))
    ResponseEntity<ConvertCurrencyResponseDTO> convert(
            @Parameter(hidden = true) @Valid @RequestBody ConvertCurrencyRequestDTO dto);
}
