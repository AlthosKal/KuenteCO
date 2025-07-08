package com.example.back_end.KuentecoChat;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class KuentecoChatApplication {

	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.load();

		// Configuracion de la base de datos
		System.setProperty("MONGO_URI", dotenv.get("MONGO_URI"));

		// Conexión al modelo de OpenAI
		System.setProperty("OPENAI_KEY", dotenv.get("OPENAI_KEY"));
		System.setProperty("OPENAI_MODEL", dotenv.get("OPENAI_MODEL"));

		//Conexión al modelo de DeepSeek
		System.setProperty("DEEPSEEK_KEY", dotenv.get("DEEPSEEK_KEY"));
		System.setProperty("DEEPSEEK_MODEL", dotenv.get("DEEPSEEK_MODEL"));
		System.setProperty("DEEPSEEK_BASE_URL", dotenv.get("DEEPSEEK_BASE_URL"));

		// Conexion con el microservicio que contiene la logica de negocio
		System.setProperty("AI_PROFILE_APP_URL", dotenv.get("AI_PROFILE_APP_URL"));

		// Secret de Jwt
		System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));
		SpringApplication.run(KuentecoChatApplication.class, args);
	}

}
