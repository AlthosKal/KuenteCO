package org.kuenteco.backend.config.api;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
@RequiredArgsConstructor
public class WebClientConfig {
    private final BancolombiaProperties props;

    @Bean("authWebClient")
    public WebClient authWebClient() {
        return WebClient.builder()
                .baseUrl(
                        props.getSandbox().getBaseUrl()
                                + props.getSandbox().getAuth().getTokenUrlBasePath())
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .defaultHeader(
                        "X-IBM-Client-Secret", props.getSandbox().getAuth().getClientSecret())
                .defaultHeader("message-id", UUID.randomUUID().toString())
                .build();
    }

    @Bean("apiWebClient")
    public WebClient apiWebClient() {
        return WebClient.builder()
                .baseUrl(
                        props.getSandbox().getBaseUrl() + props.getSandbox().getApi().getBasePath())
                .defaultHeader(HttpHeaders.CONTENT_TYPE, "application/vnd.bancolombia.v4+json")
                .defaultHeader(HttpHeaders.ACCEPT, "application/vnd.bancolombia.v4+json")
                .defaultHeader("User-Agent", "KuentecoApp/1.0")
                .build();
    }
}
