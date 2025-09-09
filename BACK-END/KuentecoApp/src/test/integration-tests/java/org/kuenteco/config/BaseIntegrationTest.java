package org.kuenteco.config;

import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;

/**
 * Clase base para todas las pruebas de integración. Configura automáticamente TestContainers para
 * PostgreSQL y WireMock para servicios externos.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("integration-test")
@TestPropertySource(
        properties = {
            // Configuraciones de base de datos para tests
            "spring.jpa.hibernate.ddl-auto=create-drop",
            "spring.jpa.show-sql=false",
            "spring.jpa.properties.hibernate.format_sql=true",
            "spring.jpa.properties.hibernate.use_sql_comments=true",

            // Configuraciones de Flyway para tests
            "spring.flyway.clean-disabled=false",
            "spring.flyway.locations=classpath:db/migration,classpath:db/test-data",

            // Configuraciones de logging para tests
            "logging.level.org.springframework.web=DEBUG",
            "logging.level.org.kuenteco=DEBUG",
            "logging.level.org.testcontainers=INFO",
            "logging.level.com.github.tomakehurst.wiremock=INFO",

            // Deshabilitar métricas y actuator para tests
            "management.endpoints.enabled-by-default=false",
            "management.endpoint.health.enabled=true",

            // Configuraciones de seguridad para tests
            "spring.security.oauth2.client.registration.google.client-id=test-client-id",
            "spring.security.oauth2.client.registration.google.client-secret=test-client-secret",

            // Configuraciones requeridas para SecurityConfig
            "WEB_URL=http://localhost:3000",
            "front-end.web-url=http://localhost:3000",
            "front-end.mobile-url=http://localhost:3001"
        })
@ExtendWith({PostgreSQLTestContainerConfig.class, WireMockConfig.class})
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
public abstract class BaseIntegrationTest {

    /** Método helper para obtener la URL de la base de datos de tests */
    protected String getDatabaseUrl() {
        return PostgreSQLTestContainerConfig.getJdbcUrl();
    }

    /** Método helper para obtener la URL base de WireMock */
    protected String getWireMockBaseUrl() {
        return WireMockConfig.getBaseUrl();
    }

    /** Método helper para resetear los mocks entre tests si es necesario */
    protected void resetWireMocks() {
        WireMockConfig.resetMocks();
    }
}
