package com.example.back_end.KuentecoChat.connector;

import com.example.back_end.KuentecoChat.connector.config.EndpointConfiguration;
import com.example.back_end.KuentecoChat.connector.config.HostConfiguration;
import com.example.back_end.KuentecoChat.connector.config.HttpConnectorConfiguration;
import com.example.back_end.KuentecoChat.connector.rest.GetTransactionDTO;
import com.example.back_end.KuentecoChat.exception.ApiResponse;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import io.netty.handler.timeout.WriteTimeoutHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.netty.http.client.HttpClient;

import java.util.List;
import java.util.concurrent.TimeUnit;

@Component
public class KuentecoAppConnector {
    private static final Logger LOGGER = LoggerFactory.getLogger(KuentecoAppConnector.class);
    private static final String HOST = "ai-profile-app";
    private static final String ENDPOINT = "get-ai-profile-info";

    private final HttpConnectorConfiguration configuration;
    private final ObjectMapper objectMapper;

    @Autowired
    public KuentecoAppConnector(HttpConnectorConfiguration configuration) {
        this.configuration = configuration;
        this.objectMapper = new ObjectMapper();
    }

    public ApiResponse<List<GetTransactionDTO>> incomesAndExpensesByPeriodFunction(String from, String to, String kind) {
        return callAiProfileApp(from, to, kind, "incomesAndExpensesByPeriodFunction");
    }

    public ApiResponse<List<GetTransactionDTO>> balanceOverTimeFunction(String from, String to, String kind) {
        return callAiProfileApp(from, to, kind, "balanceOverTimeFunction");
    }

    private ApiResponse<List<GetTransactionDTO>> callAiProfileApp(String from, String to, String kind, String pathName) {
        LOGGER.info("Calling ai-profile-app [{}] - from: {}, to: {}, kind: {}", pathName, from, to, kind);

        try {
            String jwtToken = extractJwtFromSecurityContext();
            if (jwtToken == null || jwtToken.isEmpty()) {
                String msg = "Authentication token not available";
                LOGGER.error(msg);
                return (ApiResponse<List<GetTransactionDTO>>) (ApiResponse<?>) ApiResponse.error(msg, pathName);
            }

            HostConfiguration hostConfiguration = configuration.getHosts().get(HOST);
            EndpointConfiguration endpointConfiguration = hostConfiguration.getEndpoints().get(ENDPOINT);

            HttpClient httpClient = createHttpClient(endpointConfiguration);

            UriComponentsBuilder uriBuilder = UriComponentsBuilder
                    .fromHttpUrl("http://" + hostConfiguration.getHost() + endpointConfiguration.getUrl());

            if (from != null && !from.isEmpty()) uriBuilder.queryParam("from", from);
            if (to != null && !to.isEmpty()) uriBuilder.queryParam("to", to);
            if (kind != null && !kind.isEmpty()) uriBuilder.queryParam("kind", kind);

            String finalUrl = uriBuilder.toUriString();
            LOGGER.info("Request URL: {}", finalUrl);

            WebClient client = WebClient.builder()
                    .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
                    .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + jwtToken)
                    .clientConnector(new ReactorClientHttpConnector(httpClient))
                    .build();

            String responseBody = client.get()
                    .uri(finalUrl)
                    .retrieve()
                    .onStatus(HttpStatus.UNAUTHORIZED::equals, response -> {
                        String msg = "Authentication failed - Invalid or expired token";
                        LOGGER.error(msg);
                        return response.createException().flatMap(ex -> {
                            throw new RuntimeException(msg);
                        });
                    })
                    .onStatus(status -> status.is4xxClientError(), response -> {
                        String msg = "Client error: " + response.statusCode();
                        LOGGER.error(msg);
                        return response.createException().flatMap(ex -> {
                            throw new RuntimeException(msg);
                        });
                    })
                    .onStatus(status -> status.is5xxServerError(), response -> {
                        String msg = "Server error: " + response.statusCode();
                        LOGGER.error(msg);
                        return response.createException().flatMap(ex -> {
                            throw new RuntimeException(msg);
                        });
                    })
                    .bodyToMono(String.class)
                    .block();
            LOGGER.debug("Respuesta obtenida: {}", responseBody);

            // Parsear la respuesta JSON completa
            JsonNode rootNode = objectMapper.readTree(responseBody);

            // Verificar si la respuesta es correcta
            boolean success = rootNode.has("success") && rootNode.get("success").asBoolean();

            if (!success) {
                String errorMsg = rootNode.has("message") ? rootNode.get("message").asText() : "Unknown error";
                LOGGER.error("API returned error: {}", errorMsg);
                return (ApiResponse<List<GetTransactionDTO>>) (ApiResponse<?>) ApiResponse.error(errorMsg, pathName);
            }

            // Extraer el array de datos
            JsonNode dataNode = rootNode.get("data");
            if (dataNode == null || !dataNode.isArray()) {
                LOGGER.warn("No data array found in response");
                return ApiResponse.ok("No transactions found", List.of(), pathName);
            }

            // Convertir el array de datos a List<GetTransactionDTO>
            List<GetTransactionDTO> result = objectMapper.convertValue(
                    dataNode,
                    new TypeReference<List<GetTransactionDTO>>() {}
            );

            LOGGER.info("Successfully parsed {} transactions", result.size());
            LOGGER.debug("Parsed transactions: {}", result);

            return ApiResponse.ok("Successful request", result, pathName);

        } catch (WebClientResponseException e) {
            LOGGER.error("WebClient error: {} - Body: {}", e.getMessage(), e.getResponseBodyAsString(), e);
            return (ApiResponse<List<GetTransactionDTO>>) (ApiResponse<?>) ApiResponse.error("WebClient error: " + e.getMessage(), pathName);
        } catch (Exception e) {
            LOGGER.error("Unexpected error calling ai-profile-app: {}", e.getMessage(), e);
            return (ApiResponse<List<GetTransactionDTO>>) (ApiResponse<?>) ApiResponse.error("Unexpected error: " + e.getMessage(), pathName);
        }
    }

    private HttpClient createHttpClient(EndpointConfiguration endpointConfiguration) {
        return HttpClient.create()
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, Math.toIntExact(endpointConfiguration.getConnectionTimeout()))
                .doOnConnected(conn ->
                        conn.addHandler(new ReadTimeoutHandler(endpointConfiguration.getReadTimeout(), TimeUnit.MILLISECONDS))
                                .addHandler(new WriteTimeoutHandler(endpointConfiguration.getWriteTimeout(), TimeUnit.MILLISECONDS))
                );
    }

    private String extractJwtFromSecurityContext() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null) {
                LOGGER.warn("No authentication in SecurityContext");
                return null;
            }

            Object credentials = authentication.getCredentials();
            if (credentials instanceof String) {
                LOGGER.debug("JWT token extracted from SecurityContext");
                return (String) credentials;
            }

            LOGGER.warn("Unexpected credentials type: {}", credentials != null ? credentials.getClass().getSimpleName() : "null");
            return null;
        } catch (Exception e) {
            LOGGER.error("Error extracting JWT: {}", e.getMessage(), e);
            return null;
        }
    }
}
