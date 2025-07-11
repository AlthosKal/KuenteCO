package com.example.back_end.connector.config;

import java.util.Map;
import lombok.Data;

@Data
public class HostConfiguration {

    // Dirección base (por ejemplo: localhost:8080)
    private String host;

    // Prefijo de ruta para ese grupo (por ejemplo: /api/app/v1/transaction)
    private String basePath;

    // Map de endpoints definidos dentro de esa categoría
    private Map<String, EndpointConfiguration> endpoints;
}
