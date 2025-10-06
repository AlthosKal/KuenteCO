package com.example.back_end;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class KuentecoChatApplication {

    public static void main(String[] args) {
        Dotenv dotenv = Dotenv.load();

        // Configuración de la base de datos
        System.setProperty("MONGO_URI", dotenv.get("MONGO_URI"));

        // Conexión al modelo de OpenAI
        System.setProperty("OPENAI_KEY", dotenv.get("OPENAI_KEY"));
        System.setProperty("OPENAI_MODEL", dotenv.get("OPENAI_MODEL"));
        // System.setProperty("OPENAI_BASE_URL", dotenv.get("OPENAI_BASE_URL"));

        // Conexión Twilio
        System.setProperty("TWILIO_BASE_URL", dotenv.get("TWILIO_BASE_URL"));
        System.setProperty("TWILIO_ACCOUNT_SID", dotenv.get("TWILIO_ACCOUNT_SID"));
        System.setProperty("TWILIO_AUTH_TOKEN", dotenv.get("TWILIO_AUTH_TOKEN"));
        System.setProperty("TWILIO_PHONE_NUMBER", dotenv.get("TWILIO_PHONE_NUMBER"));

        // Conexion con el microservicio que contiene la logica de negocio
        System.setProperty("KUENTECO_APP_URL", dotenv.get("KUENTECO_APP_URL"));

        // Secret de Jwt
        System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));

        System.setProperty("WEB_URL", dotenv.get("WEB_URL"));
        System.setProperty("MOBILE_URL", dotenv.get("MOBILE_URL"));
        SpringApplication.run(KuentecoChatApplication.class, args);
    }
}
