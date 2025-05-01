package org.kuenteco.backend.config.database;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.flywaydb.core.Flyway;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DependsOn;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;

@Slf4j
@Configuration
@RequiredArgsConstructor
@ConditionalOnProperty(name = "spring.flyway.enabled", havingValue = "true", matchIfMissing = true)
public class FlywayConfig {

    private final Environment environment;

    /**
     * Configura Flyway para la base de datos maestra.
     * Esta configuración asegura que las migraciones se ejecuten
     * únicamente en la base de datos principal y no en réplicas.
     *
     * @param dataSource El DataSource maestro inyectado
     * @return La instancia de Flyway configurada y ejecutada
     */
    @Bean(name = "flyway")
    @DependsOn("masterDataSource")
    public Flyway flyway(@Qualifier("masterDataSource") DataSource dataSource) {
        log.info("Configurando Flyway para migraciones de base de datos");

        Flyway flyway = Flyway.configure()
                .dataSource(dataSource)
                .locations(environment.getProperty("spring.flyway.locations", "classpath:db"))
                .baselineOnMigrate(environment.getProperty("spring.flyway.baseline-on-migrate", Boolean.class, true))
                .validateOnMigrate(environment.getProperty("spring.flyway.validate-on-migrate", Boolean.class, true))
                .outOfOrder(environment.getProperty("spring.flyway.out-of-order", Boolean.class, false))
                .sqlMigrationPrefix(environment.getProperty("spring.flyway.sql-migration-prefix", "V"))
                .sqlMigrationSeparator(environment.getProperty("spring.flyway.sql-migration-separator", "__"))
                .sqlMigrationSuffixes(environment.getProperty("spring.flyway.sql-migration-suffixes", ".sql").split(","))
                .placeholders(getPlaceholders())
                .schemas(environment.getProperty("spring.flyway.schemas", "public").split(","))
                .load();

        log.info("Ejecutando migraciones Flyway");
        try {
            // Intentar reparar el historial de esquema si hay problemas
            flyway.repair();
            // Ejecutar las migraciones
            flyway.migrate();
            log.info("Migraciones Flyway completadas exitosamente");
        } catch (Exception e) {
            log.error("Error durante la migración de Flyway: {}", e.getMessage(), e);
            throw e;
        }


        return flyway;
    }

    /**
     * Recupera los placeholders configurados para usar en scripts SQL
     *
     * @return Mapa de placeholders configurados
     */
    private java.util.Map<String, String> getPlaceholders() {
        java.util.Map<String, String> placeholders = new java.util.HashMap<>();

        // Obtener properties con el prefijo flyway.placeholders
        if (environment.getProperty("spring.flyway.placeholders.application_user") != null) {
            placeholders.put("application_user",
                    environment.getProperty("spring.flyway.placeholders.application_user"));
        }

        return placeholders;
    }
}