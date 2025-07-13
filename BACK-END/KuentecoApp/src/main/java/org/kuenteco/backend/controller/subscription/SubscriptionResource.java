package org.kuenteco.backend.controller.subscription;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.security.Principal;
import org.kuenteco.backend.dto.subscription.request.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.PaymentHistoryResponseDTO;
import org.kuenteco.backend.dto.subscription.response.SubscriptionResponseDTO;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Subscription", description = "API para la gestión de suscripciones con Mercado Pago")
public interface SubscriptionResource {

    @Operation(
            description = "Crea una nueva suscripción en Mercado Pago",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "201",
                        description = "Suscripción creada exitosamente",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                CreateSubscriptionResponseDTO
                                                                        .class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"id\": \"12345\", \"status\": \"active\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation =
                                                                    CreateSubscriptionRequestDTO
                                                                            .class))),
            parameters = {
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token de autenticación",
                        required = true)
            })
    @PostMapping("/subscription")
    ResponseEntity<?> createSubscription(
            @Valid @RequestBody CreateSubscriptionRequestDTO dto,
            Principal principal,
            HttpServletRequest request);

    @Operation(
            description = "Obtiene los detalles de una suscripción específica",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Detalles de la suscripción",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                SubscriptionResponseDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"id\": \"12345\", \"status\": \"active\", \"user\": \"John Doe\" }")))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "preapprovalId",
                        description = "ID de preaprobación de la suscripción",
                        required = true),
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token de autenticación",
                        required = true)
            })
    @GetMapping("/subscription/{preapprovalId}")
    ResponseEntity<?> getSubscription(
            @PathVariable String preapprovalId, Principal principal, HttpServletRequest request);

    @Operation(
            description = "Obtiene el historial de pagos de una suscripción específica",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Historial de pagos",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema =
                                                @Schema(
                                                        implementation =
                                                                PaymentHistoryResponseDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "[ { \"transactionId\": \"123\", \"status\": \"completed\" } ]")))
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "preapprovalId",
                        description = "ID de preaprobación de la suscripción",
                        required = true),
                @Parameter(
                        in = ParameterIn.HEADER,
                        name = "Authorization",
                        description = "Token de autenticación",
                        required = true)
            })
    @GetMapping("/subscription/{preapprovalId}/payment-history")
    ResponseEntity<?> getPaymentHistory(
            @PathVariable String preapprovalId, Principal principal, HttpServletRequest request);
}
