package com.example.back_end.KuentecoChat.connector.config;

import lombok.Data;

import java.util.HashMap;

@Data
public class HostConfiguration {

    private String host;

    private int port;

    private HashMap<String, EndpointConfiguration> endpoints;

}
