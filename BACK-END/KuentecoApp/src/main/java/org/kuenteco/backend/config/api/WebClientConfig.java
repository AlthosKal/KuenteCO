package org.kuenteco.backend.config.api;

import io.netty.channel.ChannelOption;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.util.InsecureTrustManagerFactory;
import io.netty.handler.timeout.ReadTimeoutHandler;
import io.netty.handler.timeout.WriteTimeoutHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.properties.BancolombiaProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.util.ResourceUtils;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.TrustManagerFactory;
import java.io.FileInputStream;
import java.security.KeyStore;
import java.time.Duration;
import java.util.concurrent.TimeUnit;

@Configuration
@EnableConfigurationProperties(BancolombiaProperties.class)
@RequiredArgsConstructor
@Slf4j
public class WebClientConfig {

    private final BancolombiaProperties bancolombiaProperties;

    @Bean("bancolombiaWebClient")
    public WebClient bancolombiaWebClient() {
        try {
            // Crear contexto SSL si es necesario
            SslContext sslContext = createSslContext();

            // Configuración de timeout y handlers
            HttpClient httpClient = HttpClient.create()
                    .option(ChannelOption.CONNECT_TIMEOUT_MILLIS,
                            bancolombiaProperties.getSandbox().getApi().getTimeoutSeconds() * 1000)
                    .doOnConnected(conn -> conn
                            .addHandlerLast(new ReadTimeoutHandler(
                                    bancolombiaProperties.getSandbox().getApi().getTimeoutSeconds(), TimeUnit.SECONDS))
                            .addHandlerLast(new WriteTimeoutHandler(
                                    bancolombiaProperties.getSandbox().getApi().getTimeoutSeconds(), TimeUnit.SECONDS)))
                    .responseTimeout(Duration.ofSeconds(
                            bancolombiaProperties.getSandbox().getApi().getTimeoutSeconds()));

            // Aplicar SSL si está disponible
            if (sslContext != null) {
                httpClient = httpClient.secure(spec -> spec.sslContext(sslContext));
            }

            // Construcción de WebClient
            return WebClient.builder()
                    .baseUrl(bancolombiaProperties.getSandbox().getBaseUrl())
                    .clientConnector(new ReactorClientHttpConnector(httpClient))
                    .defaultHeader("Content-Type", "application/json")
                    .defaultHeader("Accept", "application/json")
                    .defaultHeader("User-Agent", "KuentecoApp/1.0")
                    .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(1024 * 1024)) // 1MB
                    .build();

        } catch (Exception e) {
            log.error("Error configurando WebClient para Bancolombia", e);
            throw new RuntimeException("Error configurando WebClient para Bancolombia", e);
        }
    }

    private SslContext createSslContext() {
        try {
            var sslConfig = bancolombiaProperties.getSandbox().getSsl();

            if (!sslConfig.isEnabled()) {
                log.info("SSL está deshabilitado (ssl.enabled=false), omitiendo configuración SSL.");
                return null;
            }

            KeyManagerFactory keyManagerFactory = null;
            TrustManagerFactory trustManagerFactory = null;

            // Keystore
            if (sslConfig.getKeystorePath() != null && !sslConfig.getKeystorePath().isEmpty()) {
                String keystoreType = sslConfig.getKeystoreType() != null
                        ? sslConfig.getKeystoreType()
                        : "PKCS12";

                KeyStore keyStore = KeyStore.getInstance(keystoreType);
                try (FileInputStream keystoreStream = new FileInputStream(
                        ResourceUtils.getFile(sslConfig.getKeystorePath()))) {
                    keyStore.load(keystoreStream, sslConfig.getKeystorePassword().toCharArray());
                }

                keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
                keyManagerFactory.init(keyStore, sslConfig.getKeystorePassword().toCharArray());
            }

            // Truststore
            if (sslConfig.getTrustStorePath() != null && !sslConfig.getTrustStorePath().isEmpty()) {
                KeyStore trustStore = KeyStore.getInstance("JKS");
                try (FileInputStream truststoreStream = new FileInputStream(
                        ResourceUtils.getFile(sslConfig.getTrustStorePath()))) {
                    trustStore.load(truststoreStream, sslConfig.getTrustStorePassword().toCharArray());
                }

                trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
                trustManagerFactory.init(trustStore);
            }

            // Construcción del contexto SSL
            SslContextBuilder builder = SslContextBuilder.forClient();

            if (keyManagerFactory != null) {
                builder.keyManager(keyManagerFactory);
            }

            if (trustManagerFactory != null) {
                builder.trustManager(trustManagerFactory);
            } else {
                log.warn("No se configuró trustStore, usando InsecureTrustManagerFactory (solo para sandbox)");
                builder.trustManager(InsecureTrustManagerFactory.INSTANCE);
            }

            return builder.build();

        } catch (Exception e) {
            log.error("Error configurando SSL para Bancolombia", e);
            return null;
        }
    }
}
