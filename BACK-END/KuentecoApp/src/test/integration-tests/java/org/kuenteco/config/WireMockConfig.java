package org.kuenteco.config;

import static com.github.tomakehurst.wiremock.client.WireMock.*;

import com.github.tomakehurst.wiremock.WireMockServer;
import com.github.tomakehurst.wiremock.client.WireMock;
import com.github.tomakehurst.wiremock.core.WireMockConfiguration;
import org.junit.jupiter.api.extension.AfterAllCallback;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Configuración de WireMock para mockear servicios externos en pruebas de integración. Esta clase
 * maneja el ciclo de vida del servidor WireMock y proporciona mocks predefinidos.
 */
public class WireMockConfig implements BeforeAllCallback, AfterAllCallback {

    private static final Logger logger = LoggerFactory.getLogger(WireMockConfig.class);

    private static final int WIREMOCK_PORT = 9999;

    private static WireMockServer wireMockServer;

    /** Obtiene la instancia del servidor WireMock */
    public static WireMockServer getWireMockServer() {
        if (wireMockServer == null) {
            wireMockServer =
                    new WireMockServer(
                            WireMockConfiguration.options()
                                    .port(WIREMOCK_PORT)
                                    .usingFilesUnderClasspath("wiremock"));
        }
        return wireMockServer;
    }

    /** Inicia el servidor WireMock antes de ejecutar los tests */
    @Override
    public void beforeAll(ExtensionContext context) {
        WireMockServer server = getWireMockServer();

        if (!server.isRunning()) {
            server.start();
            logger.info("WireMock server iniciado en puerto: {}", WIREMOCK_PORT);

            // Configurar URL base para los servicios externos
            System.setProperty(
                    "external.mercadopago.base-url", "http://localhost:" + WIREMOCK_PORT);
            System.setProperty(
                    "external.bancolombia.base-url", "http://localhost:" + WIREMOCK_PORT);
            System.setProperty("external.cloudinary.base-url", "http://localhost:" + WIREMOCK_PORT);
            System.setProperty("external.sendgrid.base-url", "http://localhost:" + WIREMOCK_PORT);

            WireMock.configureFor("localhost", WIREMOCK_PORT);

            // Configurar mocks por defecto
            setupDefaultMocks();
        }
    }

    /** Detiene el servidor WireMock después de ejecutar los tests */
    @Override
    public void afterAll(ExtensionContext context) {
        if (wireMockServer != null && wireMockServer.isRunning()) {
            wireMockServer.stop();
            logger.info("WireMock server detenido");
        }
    }

    /** Configura mocks por defecto para los servicios externos más comunes */
    private void setupDefaultMocks() {
        logger.info("Configurando mocks por defecto para servicios externos");

        // Mock para MercadoPago - Crear preferencia de pago
        stubFor(
                post(urlPathMatching("/checkout/preferences"))
                        .willReturn(
                                aResponse()
                                        .withStatus(200)
                                        .withHeader("Content-Type", "application/json")
                                        .withBody(
                                                "{\"id\": \"test-preference-id\", \"init_point\": \"http://localhost:9999/mock-payment\"}")));

        // Mock para MercadoPago - Consultar estado de pago
        stubFor(
                get(urlPathMatching("/v1/payments/.*"))
                        .willReturn(
                                aResponse()
                                        .withStatus(200)
                                        .withHeader("Content-Type", "application/json")
                                        .withBody(
                                                "{\"id\": 123456789, \"status\": \"approved\", \"status_detail\": \"accredited\"}")));

        // Mock para Bancolombia - Consulta de cuenta
        stubFor(
                get(urlPathMatching("/bancolombia/api/account/.*"))
                        .willReturn(
                                aResponse()
                                        .withStatus(200)
                                        .withHeader("Content-Type", "application/json")
                                        .withBody(
                                                "{\"accountNumber\": \"1234567890\", \"balance\": 1000000, \"status\": \"active\"}")));

        // Mock para Cloudinary - Upload de imagen
        stubFor(
                post(urlPathMatching("/v1_1/.*/image/upload"))
                        .willReturn(
                                aResponse()
                                        .withStatus(200)
                                        .withHeader("Content-Type", "application/json")
                                        .withBody(
                                                "{\"public_id\": \"test-image-id\", \"secure_url\": \"https://test.cloudinary.com/image.jpg\"}")));

        // Mock para SendGrid - Envío de email
        stubFor(
                post(urlPathMatching("/v3/mail/send"))
                        .willReturn(
                                aResponse()
                                        .withStatus(202)
                                        .withHeader("Content-Type", "application/json")));

        logger.info("Mocks por defecto configurados correctamente");
    }

    /** Resetea todos los mocks configurados y reestablece los mocks por defecto */
    public static void resetMocks() {
        if (wireMockServer != null && wireMockServer.isRunning()) {
            wireMockServer.resetAll();
            // Reconfigurar WireMock client después del reset
            WireMock.configureFor("localhost", WIREMOCK_PORT);
            // Reconfigurar los mocks por defecto después del reset
            setupDefaultMocksStatic();
            logger.debug("Todos los mocks han sido reseteados y reconfigurados");
        }
    }

    /** Método estático para configurar mocks por defecto desde resetMocks() */
    private static void setupDefaultMocksStatic() {
        logger.debug("Reconfigurando mocks por defecto para servicios externos");

        // Mock para MercadoPago - Crear preferencia de pago
        stubFor(
                post(urlPathMatching("/checkout/preferences"))
                        .willReturn(
                                aResponse()
                                        .withStatus(200)
                                        .withHeader("Content-Type", "application/json")
                                        .withBody(
                                                "{\"id\": \"test-preference-id\", \"init_point\": \"http://localhost:9999/mock-payment\"}")));

        // Mock para MercadoPago - Consultar estado de pago
        stubFor(
                get(urlPathMatching("/v1/payments/.*"))
                        .willReturn(
                                aResponse()
                                        .withStatus(200)
                                        .withHeader("Content-Type", "application/json")
                                        .withBody(
                                                "{\"id\": 123456789, \"status\": \"approved\", \"status_detail\": \"accredited\"}")));

        // Mock para Bancolombia - Consulta de cuenta
        stubFor(
                get(urlPathMatching("/bancolombia/api/account/.*"))
                        .willReturn(
                                aResponse()
                                        .withStatus(200)
                                        .withHeader("Content-Type", "application/json")
                                        .withBody(
                                                "{\"accountNumber\": \"1234567890\", \"balance\": 1000000, \"status\": \"active\"}")));

        // Mock para Cloudinary - Upload de imagen
        stubFor(
                post(urlPathMatching("/v1_1/.*/image/upload"))
                        .willReturn(
                                aResponse()
                                        .withStatus(200)
                                        .withHeader("Content-Type", "application/json")
                                        .withBody(
                                                "{\"public_id\": \"test-image-id\", \"secure_url\": \"https://test.cloudinary.com/image.jpg\"}")));

        // Mock para SendGrid - Envío de email
        stubFor(
                post(urlPathMatching("/v3/mail/send"))
                        .willReturn(
                                aResponse()
                                        .withStatus(202)
                                        .withHeader("Content-Type", "application/json")));
    }

    /** Obtiene el puerto donde está corriendo WireMock */
    public static int getPort() {
        return WIREMOCK_PORT;
    }

    /** Obtiene la URL base de WireMock */
    public static String getBaseUrl() {
        return "http://localhost:" + WIREMOCK_PORT;
    }
}
