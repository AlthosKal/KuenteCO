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

public class CalculateFinancialHealthScoreWithTransactionsFunction
        implements Function<
                CalculateFinancialHealthScoreWithTransactionsFunction.Request,
                ApiResponse<List<GetTransactionDTO>>> {

    public record Request(
            @JsonProperty(required = true, value = "from")
                    @JsonPropertyDescription("Start date in YYYY-MM-DD format")
                    String from,
            @JsonProperty(required = true, value = "to")
                    @JsonPropertyDescription("End date in YYYY-MM-DD format")
                    String to) {}

    private final KuentecoAppConnector connector;

    public CalculateFinancialHealthScoreWithTransactionsFunction(KuentecoAppConnector connector) {
        this.connector = connector;
    }

    @Override
    public ApiResponse<List<GetTransactionDTO>> apply(Request request) {
        return connector.call(
                KuentecoEndpoint.GET_USER_TRANSACTIONS,
                Map.of(
                        "from", request.from(),
                        "to", request.to()
                ),
                new TypeReference<>() {}
        );
    }

}
