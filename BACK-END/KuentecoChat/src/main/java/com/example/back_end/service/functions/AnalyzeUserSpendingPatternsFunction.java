package com.example.back_end.service.functions;

import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.connector.config.KuentecoEndpoint;
import com.example.back_end.connector.rest.transaction.GetTransactionDTO;
import com.example.back_end.exception.ApiResponse;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.core.type.TypeReference;

import java.util.List;
import java.util.Map;
import java.util.function.Function;

public class AnalyzeUserSpendingPatternsFunction
        implements Function<
                AnalyzeUserSpendingPatternsFunction.Request, ApiResponse<List<GetTransactionDTO>>> {

    public record Request(
            @JsonProperty(required = true)
                    @JsonPropertyDescription("Fecha de inicio en formato YYYY-MM-DD")
                    String startDate,
            @JsonProperty(required = true)
                    @JsonPropertyDescription("Fecha de fin en formato YYYY-MM-DD")
                    String endDate) {}

    private final KuentecoAppConnector connector;

    public AnalyzeUserSpendingPatternsFunction(KuentecoAppConnector connector) {
        this.connector = connector;
    }

    @Override
    public ApiResponse<List<GetTransactionDTO>> apply(Request request) {
        return connector.call(
                KuentecoEndpoint.GET_USER_TRANSACTIONS,
                Map.of(
                        "from", request.startDate(),
                        "to", request.endDate()
                ),
                new TypeReference<>() {}
        );
    }

}
