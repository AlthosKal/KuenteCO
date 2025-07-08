package org.kuenteco.backend.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "bancolombia.sandbox")
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
        private String tokenUrl;
        private String clientId;
        private String clientSecret;
        private String scope;
        private int tokenExpirationBufferSeconds;
    }

    @Data
    public static class Api {
        private Endpoints endpoints = new Endpoints();
        private int timeoutSeconds;
        private int maxRetries;

        @Data
        public static class Endpoints {
            private String accounts;
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
