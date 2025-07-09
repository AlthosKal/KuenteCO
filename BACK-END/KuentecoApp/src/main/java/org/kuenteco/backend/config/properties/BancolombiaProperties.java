package org.kuenteco.backend.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "bancolombia")
public class BancolombiaProperties {

    private Sandbox sandbox = new Sandbox();

    @Data
    public static class Sandbox {
        private String baseUrl;

        private Auth auth = new Auth();
        private Api api = new Api();
        private Ssl ssl = new Ssl();
    }

    @Data
    public static class Auth {
        /**
         * Ruta base para todos los endpoints de OAuth2 (p. ej.
         * "/public-bancolombia/sb/security/oauth-provider/oauth2")
         */
        private String tokenUrlBasePath;

        private String clientId;
        private String clientSecret;
        private String scope;
        private int tokenExpirationBufferSeconds;
    }

    @Data
    public static class Api {
        /**
         * Ruta base para todos los endpoints de Transactional Information (p. ej.
         * "/public-bancolombia/sb/v1/operations/.../information")
         */
        private String basePath;

        private Endpoints endpoints = new Endpoints();
        private int timeoutSeconds;
        private int maxRetries;

        @Data
        public static class Endpoints {
            /** Sólo la parte final, p. ej. "/retrieve/transactional/info" */
            private String transactions;
        }
    }

    @Data
    public static class Ssl {
        private boolean enabled;
        private String keystorePath;
        private String keystorePassword;
        private String keystoreType;
        private String trustStorePath;
        private String trustStorePassword;
    }
}
