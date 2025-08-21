package org.kuenteco.backend.config.api;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class WebClientConfig {

    private final BancolombiaProperties props;

    @Bean("authWebClient")
    public WebClient authWebClient() {
        return WebClient.builder()
                .baseUrl(props.getSandbox().getBaseUrl()) // Solo dominio
                // ✅ Content-Type correcto para OAuth2
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_FORM_URLENCODED_VALUE)
                .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
                .filter(logRequest("AUTH"))
                .filter(logResponse("AUTH"))
                .build();
    }

    @Bean("apiWebClient")
    public WebClient apiWebClient() {
        return WebClient.builder()
                .baseUrl(props.getSandbox().getBaseUrl() + props.getSandbox().getApi().getBasePath())
                // ✅ Headers exactos como en el curl
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
                // ✅ Client-Id como header por defecto si es requerido
                // .defaultHeader("X-IBM-Client-Id", props.getSandbox().getAuth().getClientId())
                .filter(logRequest("API"))
                .filter(logResponse("API"))
                .codecs(configurer ->
                        configurer.defaultCodecs().maxInMemorySize(2 * 1024 * 1024))
                .build();
    }

    private ExchangeFilterFunction logRequest(String clientType) {
        return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
            log.debug("[{}] Request: {} {}", clientType, clientRequest.method(), clientRequest.url());
            clientRequest.headers().forEach((name, values) -> {
                // Ocultar tokens y secretos en logs
                if (name.toLowerCase().contains("authorization") ||
                        name.toLowerCase().contains("secret")) {
                    log.debug("[{}] Request header: {}=***HIDDEN***", clientType, name);
                } else {
                    log.debug("[{}] Request header: {}={}", clientType, name, values);
                }
            });
            return reactor.core.publisher.Mono.just(clientRequest);
        });
    }

    private ExchangeFilterFunction logResponse(String clientType) {
        return ExchangeFilterFunction.ofResponseProcessor(clientResponse -> {
            log.debug("[{}] Response status: {}", clientType, clientResponse.statusCode());
            return reactor.core.publisher.Mono.just(clientResponse);
        });
    }
}