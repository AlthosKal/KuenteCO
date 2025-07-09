package org.kuenteco.backend.service.logic.transaction.bancolombia;

import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.BancolombiaTransactionRequestDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.TransactionalInfoResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

@Service
@Slf4j
@RequiredArgsConstructor
public class ConectaServiceImpl implements ConectaService {

    @Qualifier("apiWebClient")
    private final WebClient apiWebClient;

    private final BancolombiaAuthService authService;
    private final BancolombiaProperties props;

    @Override
    public String getTransactionsFromRequest(BancolombiaTransactionRequestDTO dto) {
        // 1. Construir cuerpo según spec
        Map<String, Object> payload =
                Map.of(
                        "data",
                        Map.of(
                                "product", dto.getProduct(),
                                "thirdParty",
                                        Map.of(
                                                "identification",
                                                Map.of(
                                                        "type", dto.getIdentificationType(),
                                                        "number", dto.getIdentificationNumber())),
                                "initialDate", dto.getInitialDate(),
                                "finalDate", dto.getFinalDate(),
                                "timeSpan", dto.getTimeSpan()));

        // 2. Obtener token y generar message-id
        String token = authService.getValidToken();
        String messageId = UUID.randomUUID().toString();

        // 3. Llamada al endpoint transaccional
        TransactionalInfoResponse response =
                apiWebClient
                        .post()
                        .uri(
                                uriBuilder ->
                                        uriBuilder
                                                .path(props.getSandbox().getApi().getBasePath())
                                                .path(
                                                        props.getSandbox()
                                                                .getApi()
                                                                .getEndpoints()
                                                                .getTransactions())
                                                .build())
                        .header("Authorization", "Bearer " + token)
                        .header("message-id", messageId)
                        // Content-Type y Accept ya vienen por defecto en el bean
                        .bodyValue(payload)
                        .retrieve()
                        .bodyToMono(TransactionalInfoResponse.class)
                        .block();

        if (response == null || response.getData() == null) {
            log.error("Respuesta nula o sin data al solicitar transactional info");
            throw new RuntimeException("Error al procesar respuesta de Bancolombia");
        }

        // 4. Devolver URL del archivo con las transacciones
        return response.getData().getFileUrl();
    }
}
