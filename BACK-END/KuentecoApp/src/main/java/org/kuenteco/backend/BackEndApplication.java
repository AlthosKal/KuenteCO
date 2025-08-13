package org.kuenteco.backend;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
@EnableAsync
public class BackEndApplication {

    public static void main(String[] args) {
        // Cargar variables de entorno desde .env
        Dotenv dotenv = Dotenv.load();

        // API de SenGrid
        System.setProperty("SENDGRID_API_KEY", dotenv.get("SENDGRID_API_KEY"));
        System.setProperty("EMAIL_SENDGRID", dotenv.get("EMAIL_SENDGRID"));
        System.setProperty("VERIFICATION_EMAIL", dotenv.get("VERIFICATION_EMAIL"));
        System.setProperty("RESET_PASSWORD", dotenv.get("RESET_PASSWORD"));

        // API de Cloudinary
        System.setProperty("CLOUDINARY_NAME", dotenv.get("CLOUDINARY_NAME"));
        System.setProperty("CLOUDINARY_API_KEY", dotenv.get("CLOUDINARY_API_KEY"));
        System.setProperty("CLOUDINARY_API_SECRET", dotenv.get("CLOUDINARY_API_SECRET"));

        // API de MercadoPago
        System.setProperty("MERCADOPAGO_ACCESS_TOKEN", dotenv.get("MERCADOPAGO_ACCESS_TOKEN"));
        System.setProperty("MERCADOPAGO_PUBLIC_KEY", dotenv.get("MERCADOPAGO_PUBLIC_KEY"));
        
        // URLs de Webhooks de MercadoPago
        System.setProperty("MERCADOPAGO_WEBHOOK_BASE_URL", dotenv.get("MERCADOPAGO_WEBHOOK_BASE_URL"));
        System.setProperty("MERCADOPAGO_WEBHOOK_PREAPPROVAL_URL", dotenv.get("MERCADOPAGO_WEBHOOK_PREAPPROVAL_URL"));
        System.setProperty("MERCADOPAGO_WEBHOOK_PAYMENT_URL", dotenv.get("MERCADOPAGO_WEBHOOK_PAYMENT_URL"));
        System.setProperty("MERCADOPAGO_WEBHOOK_GENERIC_URL", dotenv.get("MERCADOPAGO_WEBHOOK_GENERIC_URL"));
        System.setProperty("MERCADOPAGO_WEBHOOK_SECRET", dotenv.get("MERCADOPAGO_WEBHOOK_SECRET"));
        System.setProperty("MERCADOPAGO_WEBHOOK_SKIP_VALIDATION", dotenv.get("MERCADOPAGO_WEBHOOK_SKIP_VALIDATION"));

        // API de Bancolombia
        System.setProperty("BANCOLOMBIA_BASE_URL", dotenv.get("BANCOLOMBIA_BASE_URL"));
        System.setProperty("BANCOLOMBIA_CLIENT_ID", dotenv.get("BANCOLOMBIA_CLIENT_ID"));
        System.setProperty("BANCOLOMBIA_CLIENT_SECRET", dotenv.get("BANCOLOMBIA_CLIENT_SECRET"));

        // Secret de Jwt
        System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));

        // Configuracion de la base de datos master
        System.setProperty(
                "SPRING_DATASOURCE_URL_MASTER", dotenv.get("SPRING_DATASOURCE_URL_MASTER"));
        System.setProperty(
                "SPRING_DATASOURCE_USERNAME_MASTER",
                dotenv.get("SPRING_DATASOURCE_USERNAME_MASTER"));
        System.setProperty(
                "SPRING_DATASOURCE_PASSWORD_MASTER",
                dotenv.get("SPRING_DATASOURCE_PASSWORD_MASTER"));

        // Configuracion de la base de datos esclava
        System.setProperty(
                "SPRING_DATASOURCE_URL_SLAVE", dotenv.get("SPRING_DATASOURCE_URL_SLAVE"));
        System.setProperty(
                "SPRING_DATASOURCE_USERNAME_SLAVE", dotenv.get("SPRING_DATASOURCE_USERNAME_SLAVE"));
        System.setProperty(
                "SPRING_DATASOURCE_PASSWORD_SLAVE", dotenv.get("SPRING_DATASOURCE_PASSWORD_SLAVE"));

        SpringApplication.run(BackEndApplication.class, args);
    }
}
