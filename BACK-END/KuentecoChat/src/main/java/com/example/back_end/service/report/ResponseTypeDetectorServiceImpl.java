package com.example.back_end.service.report;

import com.example.back_end.connector.rest.budget.BudgetSummaryDTO;
import com.example.back_end.connector.rest.budget.BudgetVsActualDTO;
import com.example.back_end.connector.rest.debt.DebtDTO;
import com.example.back_end.connector.rest.transaction.TransactionSummaryDTO;
import com.example.back_end.connector.rest.transaction.UserProfilesWithTransactionsDTO;
import com.example.back_end.dto.response.ai.BaseDynamicResponseDTO;
import com.example.back_end.mapper.TransactionMapper;
import com.example.back_end.service.factory.DynamicResponseFactory;
import java.util.*;
import java.util.function.BiFunction;
import org.springframework.stereotype.Service;

@Service
public class ResponseTypeDetectorServiceImpl implements ResponseTypeDetectorService {

    private final DynamicResponseFactory responseFactory;
    private final TransactionMapper transactionMapper;
    private final Map<String, BiFunction<String, Object, BaseDynamicResponseDTO>> responseHandlers;

    public ResponseTypeDetectorServiceImpl(
            DynamicResponseFactory responseFactory, TransactionMapper transactionMapper) {
        this.responseFactory = responseFactory;
        this.transactionMapper = transactionMapper;
        this.responseHandlers = buildHandlers();
    }

    @Override
    public BaseDynamicResponseDTO detectAndCreateResponse(
            String prompt, String functionName, Object data) {
        return responseHandlers
                .getOrDefault(
                        functionName,
                        (p, d) ->
                                responseFactory.createSimpleTextResponse(
                                        p, "Respuesta generada por IA para: " + p))
                .apply(prompt, data);
    }

    private Map<String, BiFunction<String, Object, BaseDynamicResponseDTO>> buildHandlers() {
        Map<String, BiFunction<String, Object, BaseDynamicResponseDTO>> map = new HashMap<>();

        map.put(
                "BalanceOverTime",
                listHandler(
                        TransactionSummaryDTO.class,
                        responseFactory::createBalanceOverTimeResponse));
        map.put(
                "IncomesAndExpensesByPeriod",
                listHandler(
                        TransactionSummaryDTO.class,
                        responseFactory::createBalanceOverTimeResponse));

        map.put(
                "analyzeDebtRisk",
                listHandler(DebtDTO.class, responseFactory::createDebtAnalysisResponse));

        map.put(
                "analyzeUserSpendingPatterns",
                listHandler(
                        UserProfilesWithTransactionsDTO.class,
                        (prompt, list) ->
                                responseFactory.createSpendingPatternsResponse(
                                        prompt,
                                        transactionMapper.convertToTransactionSummaryList(list))));

        map.put(
                "calculateFinancialHealthScore",
                listHandler(
                        UserProfilesWithTransactionsDTO.class,
                        (prompt, list) ->
                                responseFactory.createFinancialHealthResponse(
                                        prompt,
                                        transactionMapper.convertToTransactionSummaryList(list))));

        map.put(
                "projectFinancialBalance",
                listHandler(
                        TransactionSummaryDTO.class,
                        responseFactory::createFinancialProjectionResponse));

        map.put(
                "suggestExpenseReductions",
                listHandler(
                        TransactionSummaryDTO.class,
                        responseFactory::createExpenseReductionResponse));

        map.put(
                "compareFinancialPeriods",
                listHandler(
                        BudgetVsActualDTO.class, responseFactory::createBudgetComparisonResponse));

        map.put(
                "financialStatement",
                listHandler(BudgetSummaryDTO.class, responseFactory::createBudgetSummaryResponse));

        return map;
    }

    private <T> BiFunction<String, Object, BaseDynamicResponseDTO> listHandler(
            Class<T> clazz, BiFunction<String, List<T>, BaseDynamicResponseDTO> handler) {
        return (prompt, data) -> {
            List<T> list = safeCastList(data, clazz);
            if (!list.isEmpty()) {
                return handler.apply(prompt, list);
            }
            return responseFactory.createSimpleTextResponse(
                    prompt, "No se encontraron datos para el análisis.");
        };
    }

    @SuppressWarnings("unchecked")
    private <T> List<T> safeCastList(Object data, Class<T> clazz) {
        if (data instanceof List<?>) {
            List<?> raw = (List<?>) data;
            if (!raw.isEmpty() && clazz.isInstance(raw.get(0))) {
                return (List<T>) raw;
            }
        }
        return Collections.emptyList();
    }
}
