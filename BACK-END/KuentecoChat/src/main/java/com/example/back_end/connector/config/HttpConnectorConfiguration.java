package com.example.back_end.connector.config;

import java.util.HashMap;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "http-connector")
public class HttpConnectorConfiguration {
    private HashMap<String, HostConfiguration> hosts;
}
