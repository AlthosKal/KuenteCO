package org.kuenteco.backend;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackEndApplication {

    public static void main(String[] args) {
        // Cargar variables de entorno desde .env
        Dotenv dotenv = Dotenv.load();
        System.setProperty("SENDGRID_API_KEY", dotenv.get("SENDGRID_API_KEY"));
        System.setProperty("SPRING_DATASOURCE_URL", dotenv.get("SPRING_DATASOURCE_URL"));
        System.setProperty("SPRING_DATASOURCE_USERNAME", dotenv.get("SPRING_DATASOURCE_USERNAME"));
        System.setProperty("SPRING_DATASOURCE_PASSWORD", dotenv.get("SPRING_DATASOURCE_PASSWORD"));
        SpringApplication.run(BackEndApplication.class, args);
    }

}
