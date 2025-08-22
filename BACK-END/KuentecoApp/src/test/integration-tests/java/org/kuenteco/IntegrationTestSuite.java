package org.kuenteco;

import org.junit.platform.suite.api.*;
import org.kuenteco.auth.AuthServiceIntegrationTest;
import org.kuenteco.transaction.TransactionServiceIntegrationTest;

/**
 * Suite principal de pruebas de integración para KuenteCO Backend.
 *
 * <p>Este es el punto de entrada para ejecutar todas las pruebas de integración. Utiliza JUnit 5
 * Platform Suite para organizar y ejecutar las pruebas en un orden específico.
 *
 * <p>Para ejecutar todas las pruebas de integración: mvn test -Dtest="IntegrationTestSuite"
 *
 * <p>Para ejecutar con perfil específico: mvn test -Dspring.profiles.active=integration-test
 * -Dtest="IntegrationTestSuite"
 */
@Suite
@SuiteDisplayName("KuenteCO Backend - Integration Tests Suite")
@SelectClasses({AuthServiceIntegrationTest.class, TransactionServiceIntegrationTest.class})
@IncludeEngines("junit-jupiter")
public class IntegrationTestSuite {
    // Esta clase sirve como punto de entrada para ejecutar todas las pruebas de integración
    // No necesita implementación, solo las anotaciones de configuración
}
