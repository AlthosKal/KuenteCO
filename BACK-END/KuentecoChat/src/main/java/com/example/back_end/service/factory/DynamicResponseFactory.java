package com.example.back_end.service.factory;

import com.example.back_end.connector.rest.budget.BudgetSummaryDTO;
import com.example.back_end.connector.rest.budget.BudgetVsActualDTO;
import com.example.back_end.connector.rest.debt.DebtDTO;
import com.example.back_end.connector.rest.transaction.TransactionSummaryDTO;
import com.example.back_end.dto.response.CharDataDTO;
import com.example.back_end.dto.response.ai.*;
import java.math.BigDecimal;
import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

@Component
public class DynamicResponseFactory {

    private static final String DEFAULT_CATEGORY = "General";
    private static final String DEFAULT_USERNAME = "Usuario";

    public BaseDynamicResponseDTO createBalanceOverTimeResponse(
            String prompt, List<TransactionSummaryDTO> data) {
        String summary = "Análisis de balance financiero a lo largo del tiempo";
        String analysis = generateBalanceAnalysis(data);

        List<CharDataDTO> chartData =
                data.stream()
                        .map(
                                item ->
                                        toCharData(
                                                item.getCategoryName(),
                                                item.getNetAmount(),
                                                DEFAULT_CATEGORY))
                        .collect(Collectors.toList());

        return new ChartDataResponseDTO(
                summary, analysis, "line", chartData, "Período", "Balance ($)");
    }

    public BaseDynamicResponseDTO createDebtAnalysisResponse(String prompt, List<DebtDTO> debts) {
        String summary = "Análisis de riesgo de deuda";
        String analysis = generateDebtAnalysis(debts);

        double totalDebt = safeSum(debts, d -> d.getPendingAmount());
        double monthlyPayment = totalDebt * 0.02;
        String riskLevel = determineRiskLevel(totalDebt);
        List<String> actionPlan = generateActionPlan(riskLevel);

        DebtRiskAnalysisDTO debtAnalysis =
                new DebtRiskAnalysisDTO(totalDebt, monthlyPayment, "N/A", riskLevel, actionPlan);
        return new DebtAnalysisResponseDTO(summary, analysis, debtAnalysis, actionPlan);
    }

    public BaseDynamicResponseDTO createSpendingPatternsResponse(
            String prompt, List<TransactionSummaryDTO> data) {
        String summary = "Análisis de patrones de gasto";
        String analysis = generateSpendingPatternsAnalysis(data);

        List<String> topCategories =
                data.stream()
                        .filter(t -> t.getTotalExpenses() != null)
                        .sorted((a, b) -> b.getTotalExpenses().compareTo(a.getTotalExpenses()))
                        .limit(3)
                        .map(TransactionSummaryDTO::getCategoryName)
                        .collect(Collectors.toList());

        double avgIncome = safeAvg(data, TransactionSummaryDTO::getTotalIncome);
        double avgExpenses = safeAvg(data, TransactionSummaryDTO::getTotalExpenses);

        List<String> trends =
                List.of(
                        "Gastos variables en entretenimiento",
                        "Ingresos estables mes a mes",
                        "Tendencia al alza en gastos de alimentación");

        return new SpendingPatternResponseDTO(
                summary, analysis, topCategories, avgIncome, avgExpenses, trends);
    }

    public BaseDynamicResponseDTO createFinancialHealthResponse(
            String prompt, List<TransactionSummaryDTO> data) {
        String summary = "Evaluación de salud financiera";
        String analysis = generateFinancialHealthAnalysis(data);

        int score = calculateHealthScore(data);
        String grade = determineGrade(score);
        List<String> suggestions = generateHealthSuggestions(score);

        FinancialHealthScoreDTO healthScore =
                new FinancialHealthScoreDTO(score, grade, suggestions);
        return new FinancialHealthResponseDTO(summary, analysis, healthScore);
    }

    public BaseDynamicResponseDTO createSimpleTextResponse(String prompt, String content) {
        return new SimpleTextResponseDTO(
                "Respuesta general", "Análisis basado en la consulta del usuario", content);
    }

    public BaseDynamicResponseDTO createExpenseReductionResponse(
            String prompt, List<TransactionSummaryDTO> data) {
        String summary = "Sugerencias para reducción de gastos";
        String analysis = generateExpenseReductionAnalysis(data);

        List<ExpenseReductionSuggestionDTO> suggestions =
                List.of(
                        new ExpenseReductionSuggestionDTO(
                                "Entretenimiento",
                                500.0,
                                425.0,
                                "Limitar salidas a restaurantes y entretenimiento"),
                        new ExpenseReductionSuggestionDTO(
                                "Transporte",
                                300.0,
                                270.0,
                                "Usar transporte público o compartir viajes"),
                        new ExpenseReductionSuggestionDTO(
                                "Servicios",
                                150.0,
                                138.0,
                                "Cancelar servicios que no uses frecuentemente"));

        double potentialSavings = safeSum(data, TransactionSummaryDTO::getTotalExpenses) * 0.12;

        return new ExpenseReductionResponseDTO(summary, analysis, suggestions, potentialSavings);
    }

    public BaseDynamicResponseDTO createFinancialProjectionResponse(
            String prompt, List<TransactionSummaryDTO> data) {
        String summary = "Proyección financiera";
        String analysis = generateFinancialProjectionAnalysis(data);

        double avgIncome = safeAvg(data, TransactionSummaryDTO::getTotalIncome);
        double avgExpenses = safeAvg(data, TransactionSummaryDTO::getTotalExpenses);
        double projectedBalance = (avgIncome - avgExpenses) * 6;

        String riskAssessment = assessProjectionRisk(avgIncome, avgExpenses);
        boolean deficit = projectedBalance < 0;

        FinancialProjectionDTO projection =
                new FinancialProjectionDTO(
                        projectedBalance,
                        deficit,
                        deficit ? "Próximo mes" : "Ninguno",
                        riskAssessment);

        return new FinancialProjectionResponseDTO(summary, analysis, projection);
    }

    public BaseDynamicResponseDTO createBudgetComparisonResponse(
            String prompt, List<BudgetVsActualDTO> data) {
        String summary = "Comparación de presupuesto vs gastos reales";
        String analysis = generateBudgetComparisonAnalysis(data);

        List<CharDataDTO> chartData =
                data.stream()
                        .map(
                                item ->
                                        toCharData(
                                                item.getCategoryName(),
                                                item.getAssignedAmount(),
                                                DEFAULT_CATEGORY))
                        .collect(Collectors.toList());

        return new ChartDataResponseDTO(
                summary, analysis, "bar", chartData, "Categoría", "Monto ($)");
    }

    public BaseDynamicResponseDTO createBudgetSummaryResponse(
            String prompt, List<BudgetSummaryDTO> data) {
        String summary = "Resumen del estado del presupuesto";
        String analysis = generateBudgetSummaryAnalysis(data);

        List<CharDataDTO> chartData =
                data.stream()
                        .map(
                                item ->
                                        toCharData(
                                                item.getUsername(),
                                                item.getTotalBudgetAmount(),
                                                DEFAULT_USERNAME))
                        .collect(Collectors.toList());

        return new ChartDataResponseDTO(
                summary, analysis, "pie", chartData, "Categoría", "Presupuesto ($)");
    }

    // ----------------------
    // Métodos auxiliares
    // ----------------------

    private CharDataDTO toCharData(String label, BigDecimal value, String fallbackLabel) {
        return new CharDataDTO(
                label != null ? label : fallbackLabel, value != null ? value.doubleValue() : 0.0);
    }

    private <T> double safeSum(List<T> list, Function<T, BigDecimal> mapper) {
        return list.stream()
                .map(mapper)
                .filter(v -> v != null)
                .mapToDouble(BigDecimal::doubleValue)
                .sum();
    }

    private <T> double safeAvg(List<T> list, Function<T, BigDecimal> mapper) {
        return list.stream()
                .map(mapper)
                .filter(v -> v != null)
                .mapToDouble(BigDecimal::doubleValue)
                .average()
                .orElse(0.0);
    }

    private String generateBalanceAnalysis(List<TransactionSummaryDTO> data) {
        if (data.isEmpty()) return "No hay datos disponibles para el análisis.";

        double totalBalance = safeSum(data, TransactionSummaryDTO::getNetAmount);

        return totalBalance > 0
                ? "El balance general es positivo, indicando una buena gestión financiera."
                : "El balance muestra un déficit que requiere atención inmediata.";
    }

    private String generateDebtAnalysis(List<DebtDTO> debts) {
        if (debts.isEmpty()) return "No se encontraron deudas activas.";

        long active = debts.stream().filter(d -> d.getState().name().equals("ACTIVE")).count();
        return String.format("Se encontraron %d deudas activas que requieren seguimiento.", active);
    }

    private String generateSpendingPatternsAnalysis(List<TransactionSummaryDTO> data) {
        return data.isEmpty()
                ? "No hay patrones de gasto disponibles."
                : "Se identificaron patrones de gasto consistentes con oportunidades de optimización.";
    }

    private String generateFinancialHealthAnalysis(List<TransactionSummaryDTO> data) {
        return data.isEmpty()
                ? "No hay suficientes datos para evaluar la salud financiera."
                : "La evaluación considera ingresos, gastos y tendencias de comportamiento financiero.";
    }

    private String generateExpenseReductionAnalysis(List<TransactionSummaryDTO> data) {
        if (data.isEmpty()) return "No hay datos disponibles para generar sugerencias.";

        double total = safeSum(data, TransactionSummaryDTO::getTotalExpenses);
        return String.format(
                "Se analizaron gastos por un total de $%.2f. Se identificaron oportunidades de ahorro.",
                total);
    }

    private String generateFinancialProjectionAnalysis(List<TransactionSummaryDTO> data) {
        return data.isEmpty()
                ? "No hay datos suficientes para generar proyecciones."
                : "Proyección basada en tendencias históricas de ingresos y gastos de los últimos meses.";
    }

    private String generateBudgetComparisonAnalysis(List<BudgetVsActualDTO> data) {
        if (data.isEmpty()) return "No hay datos de comparación disponibles.";

        long over =
                data.stream()
                        .filter(i -> i.getAssignedAmount() != null && i.getActualSpent() != null)
                        .filter(i -> i.getActualSpent().compareTo(i.getAssignedAmount()) > 0)
                        .count();

        return String.format(
                "De %d categorías analizadas, %d excedieron el presupuesto asignado.",
                data.size(), over);
    }

    private String generateBudgetSummaryAnalysis(List<BudgetSummaryDTO> data) {
        if (data.isEmpty()) return "No hay información de presupuesto disponible.";

        double total = safeSum(data, BudgetSummaryDTO::getTotalBudgetAmount);
        return String.format(
                "Presupuesto total asignado: $%.2f distribuido en %d categorías.",
                total, data.size());
    }

    private String determineRiskLevel(double totalDebt) {
        if (totalDebt < 10000) return "Bajo";
        if (totalDebt < 50000) return "Medio";
        return "Alto";
    }

    private List<String> generateActionPlan(String riskLevel) {
        return switch (riskLevel) {
            case "Bajo" ->
                    List.of(
                            "Mantener pagos puntuales",
                            "Considerar pago anticipado de deudas menores");
            case "Medio" ->
                    List.of(
                            "Revisar presupuesto mensual",
                            "Priorizar deudas con mayor tasa de interés",
                            "Evitar nuevas deudas innecesarias");
            case "Alto" ->
                    List.of(
                            "Buscar asesoría financiera profesional",
                            "Considerar consolidación de deudas",
                            "Implementar plan de reducción de gastos urgente");
            default -> List.of("Mantener seguimiento regular");
        };
    }

    private int calculateHealthScore(List<TransactionSummaryDTO> data) {
        if (data.isEmpty()) return 50;

        double income = safeSum(data, TransactionSummaryDTO::getTotalIncome);
        double expenses = safeSum(data, TransactionSummaryDTO::getTotalExpenses);

        if (income <= 0) return 30;

        double ratio = expenses / income;
        if (ratio < 0.5) return 90;
        if (ratio < 0.7) return 75;
        if (ratio < 0.9) return 60;
        return 40;
    }

    private String determineGrade(int score) {
        if (score >= 80) return "Excelente";
        if (score >= 65) return "Bueno";
        if (score >= 50) return "Aceptable";
        return "Crítico";
    }

    private List<String> generateHealthSuggestions(int score) {
        if (score >= 80)
            return List.of(
                    "Mantener el buen manejo financiero",
                    "Considerar aumentar el ahorro",
                    "Diversificar inversiones");
        if (score >= 50)
            return List.of(
                    "Revisar gastos innecesarios",
                    "Crear un fondo de emergencia",
                    "Optimizar el presupuesto mensual");
        return List.of(
                "Reducir gastos no esenciales urgentemente",
                "Buscar fuentes adicionales de ingresos",
                "Crear un plan de recuperación financiera");
    }

    private String assessProjectionRisk(double income, double expenses) {
        if (income <= 0) return "Alto";

        double ratio = expenses / income;
        if (ratio > 0.9) return "Alto";
        if (ratio > 0.7) return "Medio";
        return "Bajo";
    }
}
