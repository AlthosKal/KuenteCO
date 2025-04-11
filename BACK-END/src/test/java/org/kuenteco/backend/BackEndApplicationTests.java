package org.kuenteco.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@ActiveProfiles({ "master", "slave" })
@TestPropertySource(properties = { "spring.sendgrid.api-key=test_key",
        "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.sendgrid.SendGridAutoConfiguration" })
public class BackEndApplicationTests {
    @Test
    public void contextLoads() {
        // Test vacío que solo verifica que el contexto se carga
    }
}
