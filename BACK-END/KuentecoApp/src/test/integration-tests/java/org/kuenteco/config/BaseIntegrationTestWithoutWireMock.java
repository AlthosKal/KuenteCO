package org.kuenteco.config;

import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

/**
 * Clase base para pruebas de integración que NO requieren WireMock. Esta clase proporciona
 * configuración básica de base de datos y perfiles de prueba sin incluir la extensión de WireMock.
 */
@ExtendWith(PostgreSQLTestContainerConfig.class)
@ActiveProfiles("integration-test")
@TestPropertySource(locations = "classpath:application-integration-test.yml")
@Transactional
public abstract class BaseIntegrationTestWithoutWireMock {
    // Esta clase proporciona la configuración base para tests de integración
    // que no requieren servicios externos mockeados con WireMock
}
