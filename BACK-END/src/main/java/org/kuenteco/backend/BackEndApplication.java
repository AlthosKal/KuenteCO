package org.kuenteco.backend;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackEndApplication {

    public static void main(String[] args) {
        // Cargar variables de entorno desde .env
        Dotenv dotenv = Dotenv.load();
        // API de SenGrid
        System.setProperty("SENDGRID_API_KEY", dotenv.get("SENDGRID_API_KEY"));
        System.setProperty("EMAIL_SENDGRID", dotenv.get("EMAIL_SENDGRID"));

        // Secret de Jwt
        System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));

        // Configuracion de la base de datos master
        System.setProperty("SPRING_DATASOURCE_URL_MASTER", dotenv.get("SPRING_DATASOURCE_URL_MASTER"));
        System.setProperty("SPRING_DATASOURCE_USERNAME_MASTER", dotenv.get("SPRING_DATASOURCE_USERNAME_MASTER"));
        System.setProperty("SPRING_DATASOURCE_PASSWORD_MASTER", dotenv.get("SPRING_DATASOURCE_PASSWORD_MASTER"));

        // Configuracion de la base de datos esclava
        System.setProperty("SPRING_DATASOURCE_URL_SLAVE", dotenv.get("SPRING_DATASOURCE_URL_SLAVE"));
        System.setProperty("SPRING_DATASOURCE_USERNAME_SLAVE", dotenv.get("SPRING_DATASOURCE_USERNAME_SLAVE"));
        System.setProperty("SPRING_DATASOURCE_PASSWORD_SLAVE", dotenv.get("SPRING_DATASOURCE_PASSWORD_SLAVE"));

        SpringApplication.run(BackEndApplication.class, args);
    }

}
