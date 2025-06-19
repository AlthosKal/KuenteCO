package org.kuenteco.backend.config.database;

import java.util.HashMap;
import java.util.Map;
import javax.sql.DataSource;
import lombok.extern.slf4j.Slf4j;
import org.flywaydb.core.Flyway;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.core.env.Environment;

@Slf4j
@Configuration
public class FlywayMigrationInitializer implements ApplicationListener<ContextRefreshedEvent> {

    private final DataSource dataSource;
    private final Environment environment;

    @Autowired
    public FlywayMigrationInitializer(
            @Qualifier("masterDataSource") DataSource dataSource, Environment environment) {
        this.dataSource = dataSource;
        this.environment = environment;
    }

    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {
        log.info("Configurando Flyway para migraciones de base de datos");

        Flyway flyway =
                Flyway.configure()
                        .dataSource(dataSource)
                        .locations(
                                environment.getProperty("spring.flyway.locations", "classpath:db"))
                        .baselineOnMigrate(
                                environment.getProperty(
                                        "spring.flyway.baseline-on-migrate", Boolean.class, true))
                        .validateOnMigrate(
                                environment.getProperty(
                                        "spring.flyway.validate-on-migrate", Boolean.class, true))
                        .outOfOrder(
                                environment.getProperty(
                                        "spring.flyway.out-of-order", Boolean.class, false))
                        .sqlMigrationPrefix(
                                environment.getProperty("spring.flyway.sql-migration-prefix", "V"))
                        .sqlMigrationSeparator(
                                environment.getProperty(
                                        "spring.flyway.sql-migration-separator", "__"))
                        .sqlMigrationSuffixes(
                                environment
                                        .getProperty("spring.flyway.sql-migration-suffixes", ".sql")
                                        .split(","))
                        .placeholders(getPlaceholders())
                        .schemas(
                                environment
                                        .getProperty("spring.flyway.schemas", "public")
                                        .split(","))
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
    }

    /**
     * Recupera los placeholders configurados para usar en scripts SQL
     *
     * @return Mapa de placeholders configurados
     */
    private Map<String, String> getPlaceholders() {
        Map<String, String> placeholders = new HashMap<>();

        // Obtener properties con el prefijo flyway.placeholders
        if (environment.getProperty("spring.flyway.placeholders.application_user") != null) {
            placeholders.put(
                    "application_user",
                    environment.getProperty("spring.flyway.placeholders.application_user"));
        }

        return placeholders;
    }
}
