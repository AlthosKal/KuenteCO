package org.kuenteco.config;

import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

/**
 * Configuración de TestContainers para PostgreSQL en pruebas de integración. Esta clase maneja el
 * ciclo de vida del contenedor PostgreSQL para las pruebas.
 */
@Testcontainers
public class PostgreSQLTestContainerConfig implements BeforeAllCallback {

    private static final Logger logger =
            LoggerFactory.getLogger(PostgreSQLTestContainerConfig.class);

    private static final String POSTGRES_IMAGE = "postgres:17-alpine";
    private static final String DATABASE_NAME = "kuenteco_test";
    private static final String USERNAME = "test_user";
    private static final String PASSWORD = "test_password";

    private static PostgreSQLContainer<?> postgresContainer;

    /** Obtiene una instancia singleton del contenedor PostgreSQL */
    public static PostgreSQLContainer<?> getPostgresContainer() {
        if (postgresContainer == null) {
            postgresContainer =
                    new PostgreSQLContainer<>(DockerImageName.parse(POSTGRES_IMAGE))
                            .withDatabaseName(DATABASE_NAME)
                            .withUsername(USERNAME)
                            .withPassword(PASSWORD)
                            .withInitScript(
                                    "db/test-schema.sql"); // Script opcional para inicializar
            // esquemas

            logger.info("Inicializando contenedor PostgreSQL para tests de integración");
        }
        return postgresContainer;
    }

    /** Inicia el contenedor PostgreSQL antes de ejecutar los tests */
    @Override
    public void beforeAll(ExtensionContext context) {
        PostgreSQLContainer<?> container = getPostgresContainer();

        if (!container.isRunning()) {
            container.start();
            logger.info("Contenedor PostgreSQL iniciado en: {}", container.getJdbcUrl());

            // Configurar propiedades del sistema para Spring Boot (Master)
            System.setProperty("spring.datasource.url", container.getJdbcUrl());
            System.setProperty("spring.datasource.username", container.getUsername());
            System.setProperty("spring.datasource.password", container.getPassword());
            System.setProperty("spring.datasource.driver-class-name", "org.postgresql.Driver");

            // Configurar propiedades para la base de datos slave (misma instancia para pruebas)
            System.setProperty("slave.datasource.url", container.getJdbcUrl());
            System.setProperty("slave.datasource.username", container.getUsername());
            System.setProperty("slave.datasource.password", container.getPassword());
            System.setProperty("slave.datasource.driver-class-name", "org.postgresql.Driver");

            // Configurar JPA para tests
            System.setProperty("spring.jpa.hibernate.ddl-auto", "create-drop");
            System.setProperty("spring.jpa.show-sql", "false");
            System.setProperty("spring.jpa.properties.hibernate.format_sql", "true");

            // Configurar Flyway para tests (si se usa)
            System.setProperty(
                    "spring.flyway.locations", "classpath:db/migration,classpath:db/test-data");
            System.setProperty("spring.flyway.clean-disabled", "false");
        }
    }

    /** Obtiene la URL JDBC del contenedor */
    public static String getJdbcUrl() {
        return getPostgresContainer().getJdbcUrl();
    }

    /** Obtiene el nombre de usuario de la base de datos */
    public static String getUsername() {
        return getPostgresContainer().getUsername();
    }

    /** Obtiene la contraseña de la base de datos */
    public static String getPassword() {
        return getPostgresContainer().getPassword();
    }
}
