package com.example.back_end.service.function.list;

import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.connector.config.KuentecoEndpoint;
import com.example.back_end.connector.rest.auth.LoginDTO;
import com.example.back_end.connector.rest.auth.TokenResponseDTO;
import com.example.back_end.exception.ApiResponse;
import com.fasterxml.jackson.core.type.TypeReference;
import java.util.Map;
import java.util.function.Function;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public class AuthenticateUserFunction implements Function<LoginDTO, ApiResponse<TokenResponseDTO>> {
    private final KuentecoAppConnector connector;

    @Override
    public ApiResponse<TokenResponseDTO> apply(LoginDTO dto) {
        return connector.call(
                KuentecoEndpoint.AUTH_USER,
                Map.of("nameOrEmail", dto.nameOrEmail(), "password", dto.password()),
                new TypeReference<>() {});
    }
}
