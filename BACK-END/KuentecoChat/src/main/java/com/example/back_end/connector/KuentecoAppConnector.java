package com.example.back_end.connector;

import com.example.back_end.connector.config.EndpointConfiguration;
import com.example.back_end.connector.config.HostConfiguration;
import com.example.back_end.connector.config.HttpConnectorConfiguration;
import com.example.back_end.connector.config.KuentecoEndpoint;
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
import org.springframework.web.util.UriComponentsBuilder;
import reactor.netty.http.client.HttpClient;

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

    private <T> ApiResponse<T> callKuentecoApp(
            String hostKey,
            String endpointKey,
            Map<String, String> pathParams,
            Map<String, String> queryParams,
            TypeReference<T> typeReference,
            String jwtToken) {

        try {
            if (jwtToken == null || jwtToken.isEmpty()) {
                String msg = "Authentication token not available";
                LOGGER.error(msg);
                return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error(msg, endpointKey);
            }

            HostConfiguration hostConfig = configuration.getHosts().get(hostKey);
            if (hostConfig == null) {
                throw new IllegalArgumentException("Host not found: " + hostKey);
            }

            EndpointConfiguration endpointConfig = hostConfig.getEndpoints().get(endpointKey);
            if (endpointConfig == null) {
                throw new IllegalArgumentException("Endpoint not found: " + endpointKey);
            }

            // Build full URL
            String baseUrl = "http://" + hostConfig.getHost() + hostConfig.getBasePath() + endpointConfig.getUrl();
            UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(baseUrl);
            queryParams.forEach(uriBuilder::queryParam);

            String finalUrl = uriBuilder.toUriString();
            LOGGER.info("Calling URL: {}", finalUrl);

            HttpClient httpClient = createHttpClient(endpointConfig);
            WebClient client = WebClient.builder()
                    .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
                    .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + jwtToken)
                    .clientConnector(new ReactorClientHttpConnector(httpClient))
                    .build();

            String responseBody = client.get().uri(finalUrl).retrieve().bodyToMono(String.class).block();

            JsonNode rootNode = objectMapper.readTree(responseBody);
            boolean success = rootNode.has("success") && rootNode.get("success").asBoolean();

            if (!success) {
                String errorMsg = rootNode.has("message")
                        ? rootNode.get("message").asText()
                        : "Unknown error";
                LOGGER.error("API returned error: {}", errorMsg);
                return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error(errorMsg, endpointKey);
            }

            T data = objectMapper.convertValue(rootNode.get("data"), typeReference);
            return ApiResponse.ok("Successful request", data, endpointKey);

        } catch (Exception e) {
            LOGGER.error("Unexpected error calling [{}]: {}", endpointKey, e.getMessage(), e);
            return (ApiResponse<T>) (ApiResponse<?>) ApiResponse.error("Unexpected error: " + e.getMessage(), endpointKey);
        }
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
            if (auth == null) return null;
            Object credentials = auth.getCredentials();
            return credentials instanceof String ? (String) credentials : null;
        } catch (Exception e) {
            LOGGER.error("Error extracting JWT: {}", e.getMessage(), e);
            return null;
        }
    }
}
