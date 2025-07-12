package com.example.back_end.connector;

import com.example.back_end.connector.config.EndpointConfiguration;
import com.example.back_end.connector.config.HostConfiguration;
import com.example.back_end.connector.config.HttpConnectorConfiguration;
import com.example.back_end.connector.config.KuentecoEndpoint;
import com.example.back_end.connector.rest.transaction.TransactionResponseWrapper;
import com.example.back_end.connector.rest.transaction.UserProfilesWithTransactionsDTO;
import com.example.back_end.connector.rest.transaction.TransactionDetailDTO;
import com.example.back_end.exception.ApiResponse;
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
import org.springframework.http.MediaType;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.netty.http.client.HttpClient;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Component
public class KuentecoAppConnector {
    private static final Logger LOGGER = LoggerFactory.getLogger(KuentecoAppConnector.class);

    private final HttpConnectorConfiguration configuration;
    private final ObjectMapper objectMapper;

    @Autowired
    public KuentecoAppConnector(HttpConnectorConfiguration configuration, ObjectMapper objectMapper) {
        this.configuration = configuration;
        this.objectMapper = objectMapper;
        LOGGER.info("KuentecoAppConnector initialized with hosts: {}",
                configuration.getHosts() != null ? configuration.getHosts().keySet() : "null");
    }

    public <T> ApiResponse<T> call(KuentecoEndpoint endpoint,
                                   Map<String, String> queryParams,
                                   TypeReference<T> typeReference) {
        return callKuentecoApp(
                endpoint.getHostKey(),
                endpoint.getEndpointKey(),
                Map.of(),
                queryParams,
                typeReference,
                extractJwtFromSecurityContext()
        );
    }

    // Método específico para manejar respuestas variables de transacciones
    public ApiResponse<?> callTransactionEndpoint(
            KuentecoEndpoint endpoint,
            Map<String, String> queryParams) {

        return callKuentecoAppWithVariableResponse(
                endpoint.getHostKey(),
                endpoint.getEndpointKey(),
                Map.of(),
                queryParams,
                extractJwtFromSecurityContext()
        );
    }

    private <T> ApiResponse<T> callKuentecoApp(
            String hostKey,
            String endpointKey,
            Map<String, String> pathParams,
            Map<String, String> queryParams,
            TypeReference<T> typeReference,
            String jwtToken) {

        try {
            LOGGER.debug("Attempting to call API with hostKey: {}, endpointKey: {}", hostKey, endpointKey);

            if (jwtToken == null || jwtToken.isEmpty()) {
                String msg = "Authentication token not available";
                LOGGER.error(msg);
                return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error(msg, endpointKey);
            }

            LOGGER.debug("Available hosts: {}", configuration.getHosts().keySet());

            HostConfiguration hostConfig = configuration.getHosts().get(hostKey);
            if (hostConfig == null) {
                String msg = "Host not found: " + hostKey + ". Available hosts: " + configuration.getHosts().keySet();
                LOGGER.error(msg);
                throw new IllegalArgumentException(msg);
            }

            LOGGER.debug("Found host config: {}", hostConfig);
            LOGGER.debug("Available endpoints for host {}: {}", hostKey,
                    hostConfig.getEndpoints() != null ? hostConfig.getEndpoints().keySet() : "null");

            EndpointConfiguration endpointConfig = hostConfig.getEndpoints().get(endpointKey);
            if (endpointConfig == null) {
                String msg = "Endpoint not found: " + endpointKey + " for host: " + hostKey +
                        ". Available endpoints: " + (hostConfig.getEndpoints() != null ? hostConfig.getEndpoints().keySet() : "null");
                LOGGER.error(msg);
                throw new IllegalArgumentException(msg);
            }

            LOGGER.debug("Found endpoint config: {}", endpointConfig);

            // Build full URL with proper protocol
            String baseUrl = buildBaseUrl(hostConfig, endpointConfig);
            UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(baseUrl);

            // Add query parameters
            if (queryParams != null && !queryParams.isEmpty()) {
                queryParams.forEach(uriBuilder::queryParam);
            }

            String finalUrl = uriBuilder.toUriString();
            LOGGER.info("Making API call to URL: {}", finalUrl);

            HttpClient httpClient = createHttpClient(endpointConfig);
            WebClient client = WebClient.builder()
                    .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
                    .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + jwtToken)
                    .clientConnector(new ReactorClientHttpConnector(httpClient))
                    .build();

            String responseBody = client.get()
                    .uri(finalUrl)
                    .retrieve()
                    .bodyToMono(String.class)
                    .timeout(Duration.ofMillis(endpointConfig.getReadTimeout()))
                    .block();

            LOGGER.debug("API Response received: {}", responseBody);

            if (responseBody == null || responseBody.trim().isEmpty()) {
                String msg = "Empty response from API";
                LOGGER.error(msg);
                return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error(msg, endpointKey);
            }

            JsonNode rootNode = objectMapper.readTree(responseBody);
            boolean success = rootNode.has("success") && rootNode.get("success").asBoolean();

            if (!success) {
                String errorMsg = rootNode.has("message")
                        ? rootNode.get("message").asText()
                        : "API returned success=false";
                LOGGER.error("API returned error: {}", errorMsg);
                return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error(errorMsg, endpointKey);
            }

            // Extract data from response
            JsonNode dataNode = rootNode.get("data");
            if (dataNode == null) {
                LOGGER.warn("No data field in successful response");
                return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error("No data in response", endpointKey);
            }

            T data = objectMapper.convertValue(dataNode, typeReference);
            LOGGER.info("Successfully processed API response with data type: {}", data.getClass().getSimpleName());
            return ApiResponse.ok("Successful request", data, endpointKey);

        } catch (WebClientResponseException e) {
            String msg = String.format("HTTP error calling [%s]: %d - %s", endpointKey, e.getStatusCode().value(), e.getMessage());
            LOGGER.error(msg, e);
            return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error(msg, endpointKey);
        } catch (Exception e) {
            String msg = "Unexpected error calling [" + endpointKey + "]: " + e.getMessage();
            LOGGER.error(msg, e);
            return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error(msg, endpointKey);
        }
    }

    // Método específico para manejar respuestas variables
    private ApiResponse<?> callKuentecoAppWithVariableResponse(
            String hostKey,
            String endpointKey,
            Map<String, String> pathParams,
            Map<String, String> queryParams,
            String jwtToken) {

        try {
            LOGGER.debug("Attempting to call API with variable response for hostKey: {}, endpointKey: {}", hostKey, endpointKey);

            if (jwtToken == null || jwtToken.isEmpty()) {
                String msg = "Authentication token not available";
                LOGGER.error(msg);
                return ApiResponse.error(msg, endpointKey);
            }

            HostConfiguration hostConfig = configuration.getHosts().get(hostKey);
            if (hostConfig == null) {
                String msg = "Host not found: " + hostKey;
                LOGGER.error(msg);
                throw new IllegalArgumentException(msg);
            }

            EndpointConfiguration endpointConfig = hostConfig.getEndpoints().get(endpointKey);
            if (endpointConfig == null) {
                String msg = "Endpoint not found: " + endpointKey + " for host: " + hostKey;
                LOGGER.error(msg);
                throw new IllegalArgumentException(msg);
            }

            // Build full URL
            String baseUrl = buildBaseUrl(hostConfig, endpointConfig);
            UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(baseUrl);

            if (queryParams != null && !queryParams.isEmpty()) {
                queryParams.forEach(uriBuilder::queryParam);
            }

            String finalUrl = uriBuilder.toUriString();
            LOGGER.info("Making API call to URL: {}", finalUrl);

            HttpClient httpClient = createHttpClient(endpointConfig);
            WebClient client = WebClient.builder()
                    .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
                    .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + jwtToken)
                    .clientConnector(new ReactorClientHttpConnector(httpClient))
                    .build();

            String responseBody = client.get()
                    .uri(finalUrl)
                    .retrieve()
                    .bodyToMono(String.class)
                    .timeout(Duration.ofMillis(endpointConfig.getReadTimeout()))
                    .block();

            LOGGER.debug("API Response received: {}", responseBody);

            if (responseBody == null || responseBody.trim().isEmpty()) {
                String msg = "Empty response from API";
                LOGGER.error(msg);
                return ApiResponse.error(msg, endpointKey);
            }

            JsonNode rootNode = objectMapper.readTree(responseBody);
            boolean success = rootNode.has("success") && rootNode.get("success").asBoolean();

            if (!success) {
                String errorMsg = rootNode.has("message")
                        ? rootNode.get("message").asText()
                        : "API returned success=false";
                LOGGER.error("API returned error: {}", errorMsg);
                return ApiResponse.error(errorMsg, endpointKey);
            }

            // Extract data from response
            JsonNode dataNode = rootNode.get("data");
            if (dataNode == null) {
                LOGGER.warn("No data field in successful response");
                return ApiResponse.error("No data in response", endpointKey);
            }

            // Aquí es donde manejamos las respuestas variables
            TransactionResponseWrapper wrapper = processVariableResponse(dataNode);

            LOGGER.info("Successfully processed variable API response with type: {}", wrapper.getType());
            return ApiResponse.ok("Successful request", wrapper, endpointKey);

        } catch (WebClientResponseException e) {
            String msg = String.format("HTTP error calling [%s]: %d - %s", endpointKey, e.getStatusCode().value(), e.getMessage());
            LOGGER.error(msg, e);
            return ApiResponse.error(msg, endpointKey);
        } catch (Exception e) {
            String msg = "Unexpected error calling [" + endpointKey + "]: " + e.getMessage();
            LOGGER.error(msg, e);
            return ApiResponse.error(msg, endpointKey);
        }
    }

    private TransactionResponseWrapper processVariableResponse(JsonNode dataNode) {
        TransactionResponseWrapper wrapper = new TransactionResponseWrapper();

        try {
            // Intentar deserializar como UserProfilesWithTransactionsDTO
            if (dataNode.has("username") && dataNode.has("profiles")) {
                LOGGER.debug("Detected UserProfilesWithTransactionsDTO response");
                UserProfilesWithTransactionsDTO userProfiles = this.objectMapper.convertValue(dataNode, UserProfilesWithTransactionsDTO.class);
                wrapper.setUserProfiles(userProfiles);
                wrapper.setResponseType("USER_PROFILES");
                return wrapper;
            }

            // Intentar deserializar como List<TransactionDetailDTO>
            if (dataNode.isArray()) {
                LOGGER.debug("Detected List<TransactionDetailDTO> response");
                List<TransactionDetailDTO> transactionList = this.objectMapper.convertValue(dataNode, new TypeReference<List<TransactionDetailDTO>>() {});
                wrapper.setTransactionList(transactionList);
                wrapper.setResponseType("TRANSACTION_LIST");
                return wrapper;
            }

            // Si es un string simple
            if (dataNode.isTextual()) {
                LOGGER.debug("Detected String message response");
                wrapper.setMessage(dataNode.asText());
                wrapper.setResponseType("MESSAGE");
                return wrapper;
            }

            // Fallback: convertir a string
            LOGGER.warn("Unknown response format, converting to string");
            wrapper.setMessage(dataNode.toString());
            wrapper.setResponseType("MESSAGE");
            return wrapper;

        } catch (Exception e) {
            LOGGER.error("Error processing variable response: {}", e.getMessage(), e);
            wrapper.setMessage("Error processing response: " + e.getMessage());
            wrapper.setResponseType("ERROR");
            return wrapper;
        }
    }

    private String buildBaseUrl(HostConfiguration hostConfig, EndpointConfiguration endpointConfig) {
        String host = hostConfig.getHost();

        // Add protocol if not present
        if (!host.startsWith("http://") && !host.startsWith("https://")) {
            host = "http://" + host;
        }

        String basePath = hostConfig.getBasePath() != null ? hostConfig.getBasePath() : "";
        String endpointUrl = endpointConfig.getUrl() != null ? endpointConfig.getUrl() : "";

        // Improved URL construction to avoid double slashes
        StringBuilder urlBuilder = new StringBuilder(host);

        // Add base path
        if (!basePath.isEmpty()) {
            if (!basePath.startsWith("/")) {
                urlBuilder.append("/");
            }
            urlBuilder.append(basePath);
            // Remove trailing slash from base path
            if (basePath.endsWith("/")) {
                urlBuilder.setLength(urlBuilder.length() - 1);
            }
        }

        // Add endpoint URL
        if (!endpointUrl.isEmpty()) {
            if (!endpointUrl.startsWith("/")) {
                urlBuilder.append("/");
            }
            urlBuilder.append(endpointUrl);
        }

        String fullUrl = urlBuilder.toString();
        LOGGER.debug("Built URL: host={}, basePath={}, endpointUrl={} => {}", host, basePath, endpointUrl, fullUrl);

        return fullUrl;
    }

    private HttpClient createHttpClient(EndpointConfiguration endpointConfig) {
        return HttpClient.create()
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, endpointConfig.getConnectionTimeout())
                .doOnConnected(conn ->
                        conn.addHandler(new ReadTimeoutHandler(endpointConfig.getReadTimeout(), TimeUnit.MILLISECONDS))
                                .addHandler(new WriteTimeoutHandler(endpointConfig.getWriteTimeout(), TimeUnit.MILLISECONDS))
                );
    }

    private String extractJwtFromSecurityContext() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null) {
                LOGGER.debug("No authentication found in security context");
                return null;
            }

            Object credentials = auth.getCredentials();
            if (credentials instanceof String) {
                LOGGER.debug("JWT token extracted successfully");
                return (String) credentials;
            } else {
                LOGGER.debug("Credentials are not a string: {}", credentials != null ? credentials.getClass() : "null");
                return null;
            }
        } catch (Exception e) {
            LOGGER.error("Error extracting JWT: {}", e.getMessage(), e);
            return null;
        }
    }
}