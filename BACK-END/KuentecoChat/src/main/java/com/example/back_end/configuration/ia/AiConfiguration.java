package com.example.back_end.configuration.ia;

import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.service.functions.*;
import org.springframework.ai.model.function.FunctionCallback;
import org.springframework.ai.model.function.FunctionCallbackWrapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AiConfiguration {

    private final KuentecoAppConnector kuentecoAppConnector;

    public AiConfiguration(KuentecoAppConnector kuentecoAppConnector) {
        this.kuentecoAppConnector = kuentecoAppConnector;
    }

    @Bean(name = "incomesAndExpensesByPeriodFunction")
    public FunctionCallback incomesAndExpensesByPeriodFunction() {
        return FunctionCallbackWrapper.builder(
                        new IncomesAndExpensesByPeriodFunction(kuentecoAppConnector))
                .withName("IncomesAndExpensesByPeriod")
                .withDescription(
                        "Returns the total income and expense amounts grouped by the given time unit (day, week, month) between a start and end date.")
                .build();
    }

    @Bean(name = "balanceOverTimeFunction")
    public FunctionCallback balanceOverTimeFunction() {
        return FunctionCallbackWrapper.builder(new BalanceOverTimeFunction(kuentecoAppConnector))
                .withName("BalanceOverTime")
                .withDescription(
                        "Calculates the financial balance (incomes minus expenses) grouped by a specific period such as day, week, or month within a date range.")
                .build();
    }

    @Bean(name = "financialStatementFunction")
    public FunctionCallback financialStatementFunction() {
        return FunctionCallbackWrapper.builder(new FinancialStatementFunction(kuentecoAppConnector))
                .withName("FinancialStatement")
                .withDescription(
                        "Provides a financial statement for a given period including total budgeted vs actual amounts, grouped by categories.")
                .build();
    }

    @Bean(name = "compareFinancialPeriodsFunction")
    public FunctionCallback compareFinancialPeriodsFunction() {
        return FunctionCallbackWrapper.builder(
                        new CompareFinancialPeriodsFunction(kuentecoAppConnector))
                .withName("CompareFinancialPeriods")
                .withDescription(
                        "Compares the financial results (budgeted vs actual) across two periods, indicating increases or decreases.")
                .build();
    }

    @Bean(name = "analyzeUserSpendingPatternsFunction")
    public FunctionCallback analyzeUserSpendingPatternsFunction() {
        return FunctionCallbackWrapper.builder(
                        new AnalyzeUserSpendingPatternsFunction(kuentecoAppConnector))
                .withName("analyzeUserSpendingPatterns")
                .withDescription(
                        "Detecta hábitos financieros y tendencias mensuales del usuario analizando el historial de transacciones.")
                .build();
    }

    @Bean(name = "suggestExpenseReductionsFunction")
    public FunctionCallback suggestExpenseReductionsFunction() {
        return FunctionCallbackWrapper.builder(
                        new SuggestExpenseReductionsFunction(kuentecoAppConnector))
                .withName("suggestExpenseReductions")
                .withDescription(
                        "Sugiere formas de reducir gastos en diferentes categorías basándose en presupuestos actuales y gastos históricos.")
                .build();
    }

    @Bean(name = "projectFinancialBalanceFunction")
    public FunctionCallback projectFinancialBalanceFunction() {
        return FunctionCallbackWrapper.builder(
                        new ProjectFinancialBalanceFunction(kuentecoAppConnector))
                .withName("projectFinancialBalance")
                .withDescription(
                        "Proyecta el saldo financiero futuro del usuario con base en ingresos, egresos actuales y horizonte temporal.")
                .build();
    }

    @Bean(name = "calculateFinancialHealthScoreFunction")
    public FunctionCallback calculateFinancialHealthScoreFunction() {
        return FunctionCallbackWrapper.builder(
                        new CalculateFinancialHealthScoreWithTransactionsFunction(
                                kuentecoAppConnector))
                .withName("calculateFinancialHealthScore")
                .withDescription(
                        "Calcula un puntaje de salud financiera basado en deudas, ahorros, ingresos, gastos y metas.")
                .build();
    }

    @Bean(name = "analyzeDebtRiskFunction")
    public FunctionCallback analyzeDebtRiskFunction() {
        return FunctionCallbackWrapper.builder(new AnalyzeDebtRiskFunction(kuentecoAppConnector))
                .withName("analyzeDebtRisk")
                .withDescription(
                        "Evalúa el riesgo de sobreendeudamiento en función de ingresos, deudas activas y vencimientos.")
                .build();
    }
}
