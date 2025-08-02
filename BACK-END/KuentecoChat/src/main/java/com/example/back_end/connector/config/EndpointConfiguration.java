package com.example.back_end.connector.config;

import lombok.Data;

@Data
public class EndpointConfiguration {

    private String url;

    private int readTimeout;

    private int writeTimeout;

    private int connectionTimeout;
}
