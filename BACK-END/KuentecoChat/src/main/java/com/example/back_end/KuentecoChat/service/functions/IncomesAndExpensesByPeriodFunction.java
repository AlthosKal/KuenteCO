package com.example.back_end.KuentecoChat.service.functions;

import com.example.back_end.KuentecoChat.connector.KuentecoAppConnector;
import com.example.back_end.KuentecoChat.connector.rest.GetTransactionDTO;
import com.example.back_end.KuentecoChat.exception.ApiResponse;
import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;

import java.util.List;
import java.util.function.Function;

public class IncomesAndExpensesByPeriodFunction implements Function<IncomesAndExpensesByPeriodFunction.Request, ApiResponse<List<GetTransactionDTO>>> {

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
            String kind
    ) {}
    private final KuentecoAppConnector connector;

    public IncomesAndExpensesByPeriodFunction(KuentecoAppConnector connector) {
        this.connector = connector;
    }

    @Override
    public ApiResponse<List<GetTransactionDTO>> apply(Request request) {
        return connector.incomesAndExpensesByPeriodFunction(request.from(), request.to(), request.kind());
    }
}