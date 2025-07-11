package com.example.back_end.service.functions;

import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.connector.config.KuentecoEndpoint;
import com.example.back_end.connector.rest.transaction.TransactionSummaryDTO;
import com.example.back_end.exception.ApiResponse;
import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.core.type.TypeReference;

import java.util.List;
import java.util.Map;
import java.util.function.Function;

public class IncomesAndExpensesByPeriodFunction
        implements Function<
                IncomesAndExpensesByPeriodFunction.Request,
                ApiResponse<List<TransactionSummaryDTO>>> {

    @JsonClassDescription("Request for incomes and expenses by period")
    public record Request(
            @JsonProperty(required = true, value = "from")
                    @JsonPropertyDescription("Start date in YYYY-MM-DD format")
                    String from,
            @JsonProperty(required = true, value = "to")
                    @JsonPropertyDescription("End date in YYYY-MM-DD format")
                    String to,
            @JsonProperty(required = true, value = "kind")
                    @JsonPropertyDescription("Type of data to retrieve: 'incomes' or 'expenses'")
                    String kind) {}

    private final KuentecoAppConnector connector;

    public IncomesAndExpensesByPeriodFunction(KuentecoAppConnector connector) {
        this.connector = connector;
    }

    @Override
    public ApiResponse<List<TransactionSummaryDTO>> apply(Request request) {
        return connector.call(
                KuentecoEndpoint.GET_TRANSACTIONS_SUMMARY,
                Map.of("from", request.from(), "to", request.to(), "kind", request.kind()),
                new TypeReference<>() {}
        );
    }
}
