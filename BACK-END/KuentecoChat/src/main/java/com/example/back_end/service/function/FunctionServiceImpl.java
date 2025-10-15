package com.example.back_end.service.function;

import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.connector.rest.auth.LoginDTO;
import com.example.back_end.connector.rest.transaction.TransactionResponseWrapper;
import com.example.back_end.connector.rest.transaction.UserProfilesWithTransactionsDTO;
import com.example.back_end.dto.request.ChatDTO;
import com.example.back_end.service.function.list.*;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

@Service
@Slf4j
@RequiredArgsConstructor
public class FunctionServiceImpl implements FunctionService {
    private final KuentecoAppConnector kuentecoAppConnector;

    // Método auxiliar para detectar función desde el prompt
    @Override
    public String detectFunctionFromPrompt(String prompt) {
        String lowerPrompt = prompt.toLowerCase();
        String detectedFunction = "general";

        if (lowerPrompt.contains("balance") || lowerPrompt.contains("saldo")) {
            detectedFunction = "BalanceOverTime";
        } else if (lowerPrompt.contains("deuda") || lowerPrompt.contains("debt")) {
            detectedFunction = "analyzeDebtRisk";
        } else if (lowerPrompt.contains("gasto") || lowerPrompt.contains("patrón")) {
            detectedFunction = "analyzeUserSpendingPatterns";
        } else if (lowerPrompt.contains("salud financiera") || lowerPrompt.contains("score")) {
            detectedFunction = "calculateFinancialHealthScore";
        } else if (lowerPrompt.contains("ingreso") && lowerPrompt.contains("gasto")) {
            detectedFunction = "IncomesAndExpensesByPeriod";
        } else if (lowerPrompt.contains("proyección") || lowerPrompt.contains("projection")) {
            detectedFunction = "projectFinancialBalance";
        } else if (lowerPrompt.contains("reducir gastos")
                || lowerPrompt.contains("expense reduction")) {
            detectedFunction = "suggestExpenseReductions";
        } else if (lowerPrompt.contains("comparar") || lowerPrompt.contains("compare")) {
            detectedFunction = "compareFinancialPeriods";
        } else if (lowerPrompt.contains("reporte") || lowerPrompt.contains("statement")) {
            detectedFunction = "financialStatement";
        } else if (lowerPrompt.contains("transacciones") || lowerPrompt.contains("transactions")) {
            detectedFunction = "analyzeUserSpendingPatterns";
        } else if (lowerPrompt.contains("presupuesto") || lowerPrompt.contains("budget")) {
            detectedFunction = "compareFinancialPeriods";
        } else if (lowerPrompt.contains("performance") || lowerPrompt.contains("rendimiento")) {
            detectedFunction = "calculateFinancialHealthScore";
        } else if (lowerPrompt.contains("nombre de usuarío")
                || lowerPrompt.contains("contraseña")
                || lowerPrompt.contains("correo")) {
            detectedFunction = "authenticateUser";
        }
        log.info("Detected function '{}' from prompt: '{}'", detectedFunction, prompt);
        return detectedFunction;
    }

    @Override
    public Object getFunctionData(String functionName, ChatDTO request) {
        return getFunctionData(functionName, request, null);
    }

    @Override
    public Object getFunctionData(String functionName, ChatDTO request, String authToken) {
        try {
            // Si hay un token de autenticación, establecerlo en el ThreadLocal del connector
            if (authToken != null && !authToken.isEmpty()) {
                KuentecoAppConnector.setSessionToken(authToken);
                log.debug("Set session token for function: {}", functionName);
            }

            try {
                return switch (functionName) {
                    case "BalanceOverTime" -> executeBalanceFunction(request);
                    case "analyzeDebtRisk" -> executeDebtAnalysisFunction(request);
                    case "analyzeUserSpendingPatterns" -> executeSpendingPatternsFunction(request);
                    case "calculateFinancialHealthScore" -> executeFinancialHealthFunction(request);
                    case "IncomesAndExpensesByPeriod" -> executeIncomesAndExpensesFunction(request);
                    case "projectFinancialBalance" ->
                            executeProjectFinancialBalanceFunction(request);
                    case "suggestExpenseReductions" ->
                            executeSuggestExpenseReductionsFunction(request);
                    case "compareFinancialPeriods" ->
                            executeCompareFinancialPeriodsFunction(request);
                    case "financialStatement" -> executeFinancialStatementFunction(request);
                    case "authenticateUser" -> executeAuthenticateUserFunction(request);
                    default -> null;
                };
            } finally {
                // Limpiar el token del ThreadLocal después de la ejecución
                if (authToken != null && !authToken.isEmpty()) {
                    KuentecoAppConnector.clearSessionToken();
                    log.debug("Cleared session token after function execution");
                }
            }
        } catch (Exception e) {
            log.error("Error executing function: {}", functionName, e);
            // Asegurar limpieza del token en caso de excepción
            KuentecoAppConnector.clearSessionToken();
            return null;
        }
    }

    /**
     * Crea un prompt contextual que incluye información sobre los datos disponibles
     *
     * @param originalPrompt El prompt original del usuario
     * @param functionName La función detectada
     * @param functionData Los datos obtenidos de la función
     * @return Prompt mejorado con contexto
     */
    @Override
    public String createContextualPrompt(
            String originalPrompt, String functionName, Object functionData) {
        StringBuilder contextBuilder = new StringBuilder();

        // Agregar contexto sobre datos disponibles
        contextBuilder.append("📊 CONTEXTO FINANCIERO DISPONIBLE:\n");

        if (functionData != null) {
            contextBuilder.append("✅ Tengo acceso completo a tus datos financieros actuales.\n");
            contextBuilder
                    .append("📈 He analizado tu información de: ")
                    .append(functionName)
                    .append("\n");

            // Agregar información específica según el tipo de datos
            if (functionName.equals("analyzeDebtRisk") && functionData instanceof List<?> list) {
                contextBuilder
                        .append("💳 Encontré ")
                        .append(list.size())
                        .append(" deudas activas en tu perfil.\n");
            } else if (functionName.contains("Health") && functionData instanceof List<?> list) {
                contextBuilder
                        .append("💰 He calculado tu puntuaje de salud financiera basado en ")
                        .append(list.size())
                        .append(" registros.\n");
            } else if (functionData instanceof List<?> list) {
                contextBuilder
                        .append("📉 Analizé ")
                        .append(list.size())
                        .append(" registros financieros.\n");
            }
        } else {
            contextBuilder.append(
                    "⚠️ No se encontraron datos específicos para esta consulta, pero puedo brindarte asesoría general.\n");
        }

        contextBuilder.append("\n🗺️ CONSULTA DEL USUARIO:\n");
        contextBuilder.append(originalPrompt);
        contextBuilder.append("\n\n🎩 INSTRUCCIONES IMPORTANTES:\n");
        contextBuilder.append(
                "- Proporciona un análisis detallado basado en los datos disponibles\n");
        contextBuilder.append("- Si tienes datos, NO menciones que necesitas más información\n");
        contextBuilder.append("- Brinda recomendaciones específicas y actionables\n");
        contextBuilder.append("- Usa un tono profesional pero accesible\n");

        return contextBuilder.toString();
    }

    @Override
    public Prompt getPrompt(String userInput) {
        PromptTemplate promptTemplate = new PromptTemplate(loadPromptFromClasspath());

        Map<String, Object> params = Map.of("prompt", userInput);
        return promptTemplate.create(params);
    }

    // Métodos auxiliares para ejecutar funciones específicas

    @Override
    public Prompt getPrompt(ChatDTO request, String fileContent) {
        PromptTemplate promptTemplate = new PromptTemplate(loadPromptFromClasspath());

        Map<String, Object> params =
                Map.of("fileContent", fileContent, "prompt", request.getPrompt());
        return promptTemplate.create(params);
    }

    private Object executeBalanceFunction(ChatDTO request) {
        try {
            log.info("Executing balance function for prompt: {}", request.getPrompt());

            Map<String, String> params = extractDateParameters(request.getPrompt());
            log.info("Extracted parameters: {}", params);

            BalanceOverTimeFunction.Request functionRequest =
                    new BalanceOverTimeFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            log.info("Created function request: {}", functionRequest);

            BalanceOverTimeFunction function = new BalanceOverTimeFunction(kuentecoAppConnector);
            log.info("Calling balance function...");

            var response = function.apply(functionRequest);
            log.info(
                    "Function response received: success={}, data={}",
                    response.isSuccess(),
                    response.getData());

            if (!response.isSuccess()) {
                log.error("Function call failed: {}", response.getMessage());
                return null;
            }

            return response.getData();
        } catch (Exception e) {
            log.error("Error executing balance function", e);
            return null;
        }
    }

    private Object executeDebtAnalysisFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            AnalyzeDebtRiskFunction.Request functionRequest =
                    new AnalyzeDebtRiskFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            AnalyzeDebtRiskFunction function = new AnalyzeDebtRiskFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing debt analysis function", e);
            return null;
        }
    }

    private Object executeSpendingPatternsFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            AnalyzeUserSpendingPatternsFunction.Request functionRequest =
                    new AnalyzeUserSpendingPatternsFunction.Request(
                            params.get("from"), params.get("to"));

            AnalyzeUserSpendingPatternsFunction function =
                    new AnalyzeUserSpendingPatternsFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);

            if (!response.isSuccess()) {
                log.error("Function call failed: {}", response.getMessage());
                return null;
            }

            // Extraer datos del TransactionResponseWrapper
            return extractDataFromWrapper(response.getData(), "spending patterns");
        } catch (Exception e) {
            log.error("Error executing spending patterns function", e);
            return null;
        }
    }

    private Object executeFinancialHealthFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            CalculateFinancialHealthScoreWithTransactionsFunction.Request functionRequest =
                    new CalculateFinancialHealthScoreWithTransactionsFunction.Request(
                            params.get("from"), params.get("to"));

            CalculateFinancialHealthScoreWithTransactionsFunction function =
                    new CalculateFinancialHealthScoreWithTransactionsFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);

            if (!response.isSuccess()) {
                log.error("Function call failed: {}", response.getMessage());
                return null;
            }

            // Extraer datos del TransactionResponseWrapper
            return extractDataFromWrapper(response.getData(), "financial health");
        } catch (Exception e) {
            log.error("Error executing financial health function", e);
            return null;
        }
    }

    private Object executeIncomesAndExpensesFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            IncomesAndExpensesByPeriodFunction.Request functionRequest =
                    new IncomesAndExpensesByPeriodFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            IncomesAndExpensesByPeriodFunction function =
                    new IncomesAndExpensesByPeriodFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing incomes and expenses function", e);
            return "";
        }
    }

    private Object executeProjectFinancialBalanceFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            ProjectFinancialBalanceFunction.Request functionRequest =
                    new ProjectFinancialBalanceFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            ProjectFinancialBalanceFunction function =
                    new ProjectFinancialBalanceFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing project financial balance function", e);
            return null;
        }
    }

    private Object executeSuggestExpenseReductionsFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            SuggestExpenseReductionsFunction.Request functionRequest =
                    new SuggestExpenseReductionsFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            SuggestExpenseReductionsFunction function =
                    new SuggestExpenseReductionsFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing suggest expense reductions function", e);
            return null;
        }
    }

    private Object executeCompareFinancialPeriodsFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            CompareFinancialPeriodsFunction.Request functionRequest =
                    new CompareFinancialPeriodsFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            CompareFinancialPeriodsFunction function =
                    new CompareFinancialPeriodsFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing compare financial periods function", e);
            return null;
        }
    }

    private Object executeFinancialStatementFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            FinancialStatementFunction.Request functionRequest =
                    new FinancialStatementFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            FinancialStatementFunction function =
                    new FinancialStatementFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing financial statement function", e);
            return null;
        }
    }

    private Object executeAuthenticateUserFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            LoginDTO dto = new LoginDTO(params.get("nameOrEmail"), params.get("password"));

            AuthenticateUserFunction function = new AuthenticateUserFunction(kuentecoAppConnector);
            var response = function.apply(dto);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing financial statement function", e);
            return "";
        }
    }

    /**
     * Extrae parámetros de fecha y tipo desde el prompt del usuario
     *
     * @param prompt El prompt del usuario
     * @return Map con los parámetros extraídos: from, to, kind
     */
    private Map<String, String> extractDateParameters(String prompt) {
        Map<String, String> params = new HashMap<>();

        // Valores por defecto
        LocalDate now = LocalDate.now();
        String defaultFrom = now.minusMonths(3).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        String defaultTo = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        String defaultKind = "daily";

        // Patrones para extraer fechas
        Pattern datePattern = Pattern.compile("(\\d{4}-\\d{2}-\\d{2})");
        Pattern periodPattern =
                Pattern.compile("(\\d+)\\s*(día|días|semana|semanas|mes|meses|año|años)");

        String lowerPrompt = prompt.toLowerCase();

        // Extraer fechas explícitas
        Matcher dateMatcher = datePattern.matcher(prompt);
        List<String> foundDates = new ArrayList<>();
        while (dateMatcher.find()) {
            foundDates.add(dateMatcher.group(1));
        }

        if (foundDates.size() >= 2) {
            params.put("from", foundDates.get(0));
            params.put("to", foundDates.get(1));
        } else if (foundDates.size() == 1) {
            params.put("to", foundDates.get(0));
            params.put("from", defaultFrom);
        } else {
            // Extraer períodos relativos
            Matcher periodMatcher = periodPattern.matcher(lowerPrompt);
            if (periodMatcher.find()) {
                int amount = Integer.parseInt(periodMatcher.group(1));
                String unit = periodMatcher.group(2);

                LocalDate fromDate = now;
                switch (unit) {
                    case "día", "días" -> fromDate = now.minusDays(amount);
                    case "semana", "semanas" -> fromDate = now.minusWeeks(amount);
                    case "mes", "meses" -> fromDate = now.minusMonths(amount);
                    case "año", "años" -> fromDate = now.minusYears(amount);
                }

                params.put("from", fromDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                params.put("to", defaultTo);
            } else {
                // Usar valores por defecto
                params.put("from", defaultFrom);
                params.put("to", defaultTo);
            }
        }

        // Determinar el tipo de agrupación
        if (lowerPrompt.contains("diario") || lowerPrompt.contains("daily")) {
            params.put("kind", "daily");
        } else if (lowerPrompt.contains("semanal") || lowerPrompt.contains("weekly")) {
            params.put("kind", "weekly");
        } else if (lowerPrompt.contains("mensual") || lowerPrompt.contains("monthly")) {
            params.put("kind", "monthly");
        } else {
            params.put("kind", defaultKind);
        }

        log.info("Extracted parameters from prompt '{}': {}", prompt, params);
        return params;
    }

    /**
     * Extrae los datos reales del TransactionResponseWrapper
     *
     * @param data El objeto que puede ser un TransactionResponseWrapper
     * @param functionContext Contexto de la función para logging
     * @return Los datos extraídos o una lista con el UserProfilesWithTransactionsDTO
     */
    private Object extractDataFromWrapper(Object data, String functionContext) {
        try {
            if (data instanceof TransactionResponseWrapper wrapper) {
                log.info(
                        "Extracting data from TransactionResponseWrapper for {}, type: {}",
                        functionContext,
                        wrapper.getType());

                switch (wrapper.getType()) {
                    case USER_PROFILES -> {
                        // Para usuarios BUSINESS, devolver una lista con el
                        // UserProfilesWithTransactionsDTO
                        UserProfilesWithTransactionsDTO userProfiles = wrapper.getUserProfiles();
                        if (userProfiles != null) {
                            log.info(
                                    "Found user profiles data for {}: {} profiles, {} transactions",
                                    functionContext,
                                    userProfiles.getTotalProfiles(),
                                    userProfiles.getTotalTransactions());
                            return List.of(userProfiles);
                        }
                    }
                    case TRANSACTION_LIST -> {
                        // Para usuarios PERSONAL, devolver directamente la lista de transacciones
                        if (wrapper.getTransactionList() != null
                                && !wrapper.getTransactionList().isEmpty()) {
                            log.info(
                                    "Found transaction list for {}: {} transactions",
                                    functionContext,
                                    wrapper.getTransactionList().size());
                            return wrapper.getTransactionList();
                        }
                    }
                    case MESSAGE -> {
                        log.info(
                                "Received message response for {}: {}",
                                functionContext,
                                wrapper.getMessage());
                        return Collections.emptyList();
                    }
                    case UNKNOWN -> {
                        log.warn(
                                "Unknown wrapper type for {}: {}",
                                functionContext,
                                wrapper.getType());
                        return Collections.emptyList();
                    }
                }
            } else {
                log.debug(
                        "Data is not a TransactionResponseWrapper for {}, returning as-is: {}",
                        functionContext,
                        data != null ? data.getClass().getSimpleName() : "null");
                return data;
            }

            return Collections.emptyList();
        } catch (Exception e) {
            log.error(
                    "Error extracting data from wrapper for {}: {}",
                    functionContext,
                    e.getMessage(),
                    e);
            return Collections.emptyList();
        }
    }

    private String loadPromptFromClasspath() {
        try (InputStream inputStream =
                getClass()
                        .getClassLoader()
                        .getResourceAsStream("prompts/" + "ai_prompt_template.txt")) {
            if (inputStream == null) throw new FileNotFoundException("Prompt file not found");
            return StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException("Failed to load prompt template", e);
        }
    }
}
