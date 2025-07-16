package com.example.back_end.service;

import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_CONVERSATION_ID_KEY;
import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_RETRIEVE_SIZE_KEY;

import com.example.back_end.configuration.security.JwtUtil;
import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.connector.rest.transaction.TransactionResponseWrapper;
import com.example.back_end.connector.rest.transaction.UserProfilesWithTransactionsDTO;
import com.example.back_end.dto.request.ChatDTO;
import com.example.back_end.dto.request.ChatFilesDTO;
import com.example.back_end.dto.request.ChatHistoryDTO;
import com.example.back_end.dto.request.ChatMultipartDTO;
import com.example.back_end.dto.response.DynamicAnalysisResponseDTO;
import com.example.back_end.dto.response.StringChatResponseDTO;
import com.example.back_end.dto.response.CharDataDTO;
import com.example.back_end.dto.response.ai.ChartDataResponseDTO;
import com.example.back_end.dto.response.ai.BaseDynamicResponseDTO;
import com.example.back_end.entity.ChatHistory;
import com.example.back_end.enums.ApiError;
import com.example.back_end.enums.Model;
import com.example.back_end.exception.AiProfileException;
import com.example.back_end.mapper.ChatHistoryMapper;
import com.example.back_end.repository.AiHistoryRepository;
import com.example.back_end.service.functions.*;
import com.example.back_end.util.KuentecoChatUtil;
import jakarta.servlet.http.HttpServletRequest;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.client.advisor.PromptChatMemoryAdvisor;
import org.springframework.ai.chat.memory.InMemoryChatMemory;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

@Service
public class ChatServiceImpl implements ChatService {
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatServiceImpl.class);

    private final ChatClient deepseekChatClient;
    private final ChatClient openaiChatClient;
    private final AiHistoryRepository repository;
    private final ChatHistoryMapper chatHistoryMapper;
    private final ResponseTypeDetectorService responseTypeDetector;
    private final JwtUtil jwtUtil;
    private final KuentecoAppConnector kuentecoAppConnector;
    private final ReportGenerationService reportGenerationService;

    public ChatServiceImpl(
            @Qualifier(value = "openAiChatModel") ChatModel deepseekChatClient,
            @Qualifier(value = "openAiChatModel") ChatModel openaiChatClient,
            JwtUtil jwtUtil,
            AiHistoryRepository repository,
            ChatHistoryMapper chatHistoryMapper,
            ResponseTypeDetectorService responseTypeDetectorService,
            KuentecoAppConnector kuentecoAppConnector,
            ReportGenerationService reportGenerationService) {

        InMemoryChatMemory memory = new InMemoryChatMemory();

        this.deepseekChatClient =
                ChatClient.builder(deepseekChatClient)
                        .defaultAdvisors(
                                new PromptChatMemoryAdvisor(memory),
                                new MessageChatMemoryAdvisor(memory))
                        .build();

        this.openaiChatClient =
                ChatClient.builder(openaiChatClient)
                        .defaultAdvisors(
                                new PromptChatMemoryAdvisor(memory),
                                new MessageChatMemoryAdvisor(memory))
                        .build();

        this.jwtUtil = jwtUtil;
        this.repository = repository;
        this.chatHistoryMapper = chatHistoryMapper;
        this.responseTypeDetector = responseTypeDetectorService;
        this.kuentecoAppConnector = kuentecoAppConnector;
        this.reportGenerationService = reportGenerationService;
    }

    @Override
    @Cacheable(value = "chats", key = "#dto.model + '-' + #dto.prompt") // Temporarily disabled
    // to prevent stale responses
    public DynamicAnalysisResponseDTO queryAi(ChatDTO dto, HttpServletRequest request) {
        try {
            String token = jwtUtil.resolveToken(request);
            String email = jwtUtil.extractEmail(token);
            // Detectar qué función se va a ejecutar basándose en el prompt
            String detectedFunction = detectFunctionFromPrompt(dto.getPrompt());

            // Obtener datos de la función ejecutada ANTES de llamar al AI
            Object functionData = getFunctionData(detectedFunction, dto);

            // Crear contexto con información disponible
            String contextualPrompt =
                    createContextualPrompt(dto.getPrompt(), detectedFunction, functionData);

            // Ejecutar la función con el contexto mejorado
            String response =
                    getChatClient(dto.getModel())
                            .prompt()
                            .user(contextualPrompt)
                            .advisors(
                                    a ->
                                            a.param(
                                                            CHAT_MEMORY_CONVERSATION_ID_KEY,
                                                            dto.getConversationId())
                                                    .param(CHAT_MEMORY_RETRIEVE_SIZE_KEY, 100))
                            .call()
                            .content();

            if (isReportRequest(dto.getPrompt()) && functionData != null) {
                String reportType = extractReportType(dto.getPrompt());
                BaseDynamicResponseDTO reportResponse =
                        reportGenerationService.generateReportResponse(
                                dto.getPrompt(), detectedFunction, functionData, reportType);

                // Guardar historial
                if (Objects.nonNull(dto.getConversationId())) {
                    repository.save(
                            new ChatHistory(
                                    dto.getConversationId(),
                                    dto.getPrompt(),
                                    "Reporte " + reportType + " generado exitosamente",
                                    email));
                }

                ChartDataResponseDTO chartData = generateChartData(detectedFunction, functionData);
                StringChatResponseDTO dtoResponse =
                        new StringChatResponseDTO(dto.getConversationId(), response, chartData);
                return new DynamicAnalysisResponseDTO(dtoResponse, reportResponse);
            }

            // Si no es una solicitud de reporte, crear respuesta de análisis normal
            ChartDataResponseDTO chartData = generateChartData(detectedFunction, functionData);
            StringChatResponseDTO dtoResponse =
                    new StringChatResponseDTO(dto.getConversationId(), response, chartData);

            // Guardar historial
            if (Objects.nonNull(dto.getConversationId())) {
                repository.save(
                        new ChatHistory(dto.getConversationId(), dto.getPrompt(), response, email));
            }

            // Crear respuesta dinámica basada en la función detectada
            BaseDynamicResponseDTO dynamicResponse =
                    createDynamicResponse(detectedFunction, functionData, response);

            return new DynamicAnalysisResponseDTO(dtoResponse, dynamicResponse);

        } catch (Exception e) {
            LOGGER.error("Error generating dynamic response", e);
            throw new AiProfileException(ApiError.BAD_FORMAT);
        }
    }

    // Método auxiliar para dete    ctar función desde el prompt
    private String detectFunctionFromPrompt(String prompt) {
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
        }

        LOGGER.info("Detected function '{}' from prompt: '{}'", detectedFunction, prompt);
        return detectedFunction;
    }

    private Object getFunctionData(String functionName, ChatDTO request) {
        try {
            switch (functionName) {
                case "BalanceOverTime":
                    return executeBalanceFunction(request);
                case "analyzeDebtRisk":
                    return executeDebtAnalysisFunction(request);
                case "analyzeUserSpendingPatterns":
                    return executeSpendingPatternsFunction(request);
                case "calculateFinancialHealthScore":
                    return executeFinancialHealthFunction(request);
                case "IncomesAndExpensesByPeriod":
                    return executeIncomesAndExpensesFunction(request);
                case "projectFinancialBalance":
                    return executeProjectFinancialBalanceFunction(request);
                case "suggestExpenseReductions":
                    return executeSuggestExpenseReductionsFunction(request);
                case "compareFinancialPeriods":
                    return executeCompareFinancialPeriodsFunction(request);
                case "financialStatement":
                    return executeFinancialStatementFunction(request);
                default:
                    return null;
            }
        } catch (Exception e) {
            LOGGER.error("Error executing function: {}", functionName, e);
            return null;
        }
    }

    // Métodos auxiliares para ejecutar funciones específicas
    private Object executeBalanceFunction(ChatDTO request) {
        try {
            LOGGER.info("Executing balance function for prompt: {}", request.getPrompt());

            Map<String, String> params = extractDateParameters(request.getPrompt());
            LOGGER.info("Extracted parameters: {}", params);

            BalanceOverTimeFunction.Request functionRequest =
                    new BalanceOverTimeFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            LOGGER.info("Created function request: {}", functionRequest);

            BalanceOverTimeFunction function = new BalanceOverTimeFunction(getConnector());
            LOGGER.info("Calling balance function...");

            var response = function.apply(functionRequest);
            LOGGER.info(
                    "Function response received: success={}, data={}",
                    response.isSuccess(),
                    response.getData());

            if (!response.isSuccess()) {
                LOGGER.error("Function call failed: {}", response.getMessage());
                return null;
            }

            return response.getData();
        } catch (Exception e) {
            LOGGER.error("Error executing balance function", e);
            return null;
        }
    }

    private Object executeDebtAnalysisFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            AnalyzeDebtRiskFunction.Request functionRequest =
                    new AnalyzeDebtRiskFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            AnalyzeDebtRiskFunction function = new AnalyzeDebtRiskFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            LOGGER.error("Error executing debt analysis function", e);
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
                    new AnalyzeUserSpendingPatternsFunction(getConnector());
            var response = function.apply(functionRequest);

            if (!response.isSuccess()) {
                LOGGER.error("Function call failed: {}", response.getMessage());
                return null;
            }

            // Extraer datos del TransactionResponseWrapper
            return extractDataFromWrapper(response.getData(), "spending patterns");
        } catch (Exception e) {
            LOGGER.error("Error executing spending patterns function", e);
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
                    new CalculateFinancialHealthScoreWithTransactionsFunction(getConnector());
            var response = function.apply(functionRequest);

            if (!response.isSuccess()) {
                LOGGER.error("Function call failed: {}", response.getMessage());
                return null;
            }

            // Extraer datos del TransactionResponseWrapper
            return extractDataFromWrapper(response.getData(), "financial health");
        } catch (Exception e) {
            LOGGER.error("Error executing financial health function", e);
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
                    new IncomesAndExpensesByPeriodFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            LOGGER.error("Error executing incomes and expenses function", e);
            return null;
        }
    }

    private Object executeProjectFinancialBalanceFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            ProjectFinancialBalanceFunction.Request functionRequest =
                    new ProjectFinancialBalanceFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            ProjectFinancialBalanceFunction function =
                    new ProjectFinancialBalanceFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            LOGGER.error("Error executing project financial balance function", e);
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
                    new SuggestExpenseReductionsFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            LOGGER.error("Error executing suggest expense reductions function", e);
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
                    new CompareFinancialPeriodsFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            LOGGER.error("Error executing compare financial periods function", e);
            return null;
        }
    }

    private Object executeFinancialStatementFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            FinancialStatementFunction.Request functionRequest =
                    new FinancialStatementFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            FinancialStatementFunction function = new FinancialStatementFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            LOGGER.error("Error executing financial statement function", e);
            return null;
        }
    }

    public String queryAi(ChatMultipartDTO dto, HttpServletRequest request) {
        try {
            String fileContent = KuentecoChatUtil.convertFileToString(dto.getFile());
            return askToAI(dto, fileContent, request);
        } catch (Exception e) {
            throw new AiProfileException(ApiError.BAD_FORMAT);
        }
    }

    public String queryAi(ChatFilesDTO dto, HttpServletRequest request) {
        try {
            String fileContent = KuentecoChatUtil.convertFilesToString(dto.getFiles());
            return askToAI(dto, fileContent, request);
        } catch (Exception e) {
            throw new AiProfileException(ApiError.BAD_FORMAT);
        }
    }

    @Cacheable(value = "history", key = "#conversationId")
    public List<ChatHistoryDTO> getHistoryByConversationId(String conversationId) {
        return repository.findByConversationId(conversationId).stream()
                .map(chatHistoryMapper::toDTO)
                .toList();
    }

    @Override
    public List<ChatHistoryDTO> getAllConversationsOfAuthenticatedUser(HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        String email = jwtUtil.extractEmail(token);

        List<ChatHistory> allHistory = repository.findByEmail(email);

        Map<String, Optional<ChatHistory>> latestByConversation =
                allHistory.stream()
                        .collect(
                                Collectors.groupingBy(
                                        ChatHistory::getConversationId,
                                        Collectors.maxBy(
                                                Comparator.comparing(ChatHistory::getDate))));

        return latestByConversation.values().stream()
                .filter(Optional::isPresent)
                .map(Optional::get)
                .map(chatHistoryMapper::toDTO)
                .sorted(Comparator.comparing(ChatHistoryDTO::getDate).reversed())
                .toList();
    }

    @Override
    public void removeChatHistoryByConversationId(String conversationId) {
        repository.removeChatHistoriesByConversationId(conversationId);
    }

    private String askToAI(ChatDTO dto, String fileContent, HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        String email = jwtUtil.extractEmail(token);
        Prompt prompt = getPrompt(dto, fileContent);
        LOGGER.info(prompt.getInstructions().toString());

        String response =
                getChatClient(dto.getModel())
                        .prompt()
                        .user(prompt.toString())
                        .advisors(
                                a ->
                                        a.param(
                                                        CHAT_MEMORY_CONVERSATION_ID_KEY,
                                                        dto.getConversationId())
                                                .param(CHAT_MEMORY_RETRIEVE_SIZE_KEY, 100))
                        .call()
                        .content();

        // Update the interaction history
        if (Objects.nonNull(dto.getConversationId())) {
            repository.save(
                    new ChatHistory(dto.getConversationId(), dto.getPrompt(), response, email));
        }

        return response;
    }

    private Prompt getPrompt(ChatDTO request, String fileContent) {
        PromptTemplate promptTemplate =
                new PromptTemplate(loadPromptFromClasspath("ai_prompt_template.txt"));

        Map<String, Object> params =
                Map.of("fileContent", fileContent, "prompt", request.getPrompt());
        return promptTemplate.create(params);
    }

    private String loadPromptFromClasspath(String filename) {
        try (InputStream inputStream =
                getClass().getClassLoader().getResourceAsStream("prompts/" + filename)) {
            if (inputStream == null) throw new FileNotFoundException("Prompt file not found");
            return StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException("Failed to load prompt template", e);
        }
    }

    private boolean isReportRequest(String prompt) {
        String lowerPrompt = prompt.toLowerCase();
        return lowerPrompt.contains("pdf")
                || lowerPrompt.contains("excel")
                || lowerPrompt.contains("reporte")
                || lowerPrompt.contains("informe")
                || lowerPrompt.contains("exportar")
                || lowerPrompt.contains("descargar");
    }

    private String extractReportType(String prompt) {
        String lowerPrompt = prompt.toLowerCase();
        if (lowerPrompt.contains("pdf")) {
            return "PDF";
        } else if (lowerPrompt.contains("excel") || lowerPrompt.contains("xlsx")) {
            return "EXCEL";
        }
        return "PDF"; // Por defecto
    }

    private ChatClient getChatClient(Model model) {
        if (model == Model.DEEPSEEK) {
            return deepseekChatClient;

        } else if (model == Model.OPENAI) {
            return openaiChatClient;
        }
        return deepseekChatClient;
    }

    private KuentecoAppConnector getConnector() {
        return this.kuentecoAppConnector;
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

        LOGGER.info("Extracted parameters from prompt '{}': {}", prompt, params);
        return params;
    }

    /**
     * Crea un prompt contextual que incluye información sobre los datos disponibles
     *
     * @param originalPrompt El prompt original del usuario
     * @param functionName La función detectada
     * @param functionData Los datos obtenidos de la función
     * @return Prompt mejorado con contexto
     */
    private String createContextualPrompt(
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

    /**
     * Crea una respuesta dinámica basada en la función detectada
     *
     * @param functionName Nombre de la función ejecutada
     * @param functionData Datos obtenidos de la función
     * @param response Respuesta del AI
     * @return Respuesta dinámica apropiada
     */
    private BaseDynamicResponseDTO createDynamicResponse(
            String functionName, Object functionData, String response) {
        try {
            // Usar el servicio detector para crear la respuesta dinámica
            return responseTypeDetector.detectAndCreateResponse(
                    response, functionName, functionData);

        } catch (Exception e) {
            LOGGER.error("Error creating dynamic response for function: {}", functionName, e);
            // Fallback a respuesta simple en caso de error
            return responseTypeDetector.detectAndCreateResponse(response, "general", null);
        }
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
                LOGGER.info(
                        "Extracting data from TransactionResponseWrapper for {}, type: {}",
                        functionContext,
                        wrapper.getType());

                switch (wrapper.getType()) {
                    case USER_PROFILES -> {
                        // Para usuarios BUSINESS, devolver una lista con el
                        // UserProfilesWithTransactionsDTO
                        UserProfilesWithTransactionsDTO userProfiles = wrapper.getUserProfiles();
                        if (userProfiles != null) {
                            LOGGER.info(
                                    "Found user profiles data for {}: {} profiles, {} transactions",
                                    functionContext,
                                    userProfiles.getTotalProfiles(),
                                    userProfiles.getTotalTransactions());
                            return List.of(userProfiles);
                        }
                        break;
                    }
                    case TRANSACTION_LIST -> {
                        // Para usuarios PERSONAL, devolver directamente la lista de transacciones
                        if (wrapper.getTransactionList() != null
                                && !wrapper.getTransactionList().isEmpty()) {
                            LOGGER.info(
                                    "Found transaction list for {}: {} transactions",
                                    functionContext,
                                    wrapper.getTransactionList().size());
                            return wrapper.getTransactionList();
                        }
                        break;
                    }
                    case MESSAGE -> {
                        LOGGER.info(
                                "Received message response for {}: {}",
                                functionContext,
                                wrapper.getMessage());
                        return Collections.emptyList();
                    }
                    case UNKNOWN -> {
                        LOGGER.warn(
                                "Unknown wrapper type for {}: {}",
                                functionContext,
                                wrapper.getType());
                        return Collections.emptyList();
                    }
                }
            } else {
                LOGGER.debug(
                        "Data is not a TransactionResponseWrapper for {}, returning as-is: {}",
                        functionContext,
                        data != null ? data.getClass().getSimpleName() : "null");
                return data;
            }

            return Collections.emptyList();
        } catch (Exception e) {
            LOGGER.error(
                    "Error extracting data from wrapper for {}: {}",
                    functionContext,
                    e.getMessage(),
                    e);
            return Collections.emptyList();
        }
    }

    /**
     * Genera datos de gráfico basados en la función detectada y los datos disponibles
     *
     * @param functionName La función detectada
     * @param functionData Los datos obtenidos de la función
     * @return ChartDataResponseDTO con los datos del gráfico o null si no aplica
     */
    private ChartDataResponseDTO generateChartData(String functionName, Object functionData) {
        try {
            if (functionData == null) {
                return null;
            }

            switch (functionName) {
                case "BalanceOverTime":
                    return generateBalanceChart(functionData);
                case "IncomesAndExpensesByPeriod":
                    return generateIncomeExpenseChart(functionData);
                case "analyzeUserSpendingPatterns":
                case "calculateFinancialHealthScore":
                    return generateTransactionChart(functionData);
                case "analyzeDebtRisk":
                    return generateDebtChart(functionData);
                case "compareFinancialPeriods":
                    return generateBudgetComparisonChart(functionData);
                default:
                    return null;
            }
        } catch (Exception e) {
            LOGGER.warn("Error generating chart data for function {}: {}", functionName, e.getMessage());
            return null;
        }
    }

    private ChartDataResponseDTO generateBalanceChart(Object data) {
        if (!(data instanceof List<?> list)) {
            return null;
        }

        List<CharDataDTO> chartData = new ArrayList<>();
        for (Object item : list) {
            try {
                String category = getFieldValue(item, "categoryName", String.class, "N/A");
                Double amount = getFieldValue(item, "netAmount", Double.class, 0.0);
                if (amount == null) {
                    Object amountObj = getFieldValue(item, "netAmount", Object.class, null);
                    if (amountObj != null) {
                        amount = Double.parseDouble(amountObj.toString());
                    } else {
                        amount = 0.0;
                    }
                }
                chartData.add(new CharDataDTO(category, amount));
            } catch (Exception e) {
                LOGGER.debug("Error processing balance item: {}", e.getMessage());
            }
        }

        return new ChartDataResponseDTO(
                "Balance por Categoría",
                "Distribución del balance neto por categoría de transacciones",
                "bar",
                chartData,
                "Categorías",
                "Balance ($)"
        );
    }

    private ChartDataResponseDTO generateIncomeExpenseChart(Object data) {
        if (!(data instanceof List<?> list)) {
            return null;
        }

        List<CharDataDTO> chartData = new ArrayList<>();
        for (Object item : list) {
            try {
                String category = getFieldValue(item, "categoryName", String.class, "N/A");
                Double expenses = getFieldValue(item, "totalExpenses", Double.class, 0.0);
                if (expenses == null) {
                    Object expensesObj = getFieldValue(item, "totalExpenses", Object.class, null);
                    if (expensesObj != null) {
                        expenses = Double.parseDouble(expensesObj.toString());
                    } else {
                        expenses = 0.0;
                    }
                }
                if (expenses > 0) {
                    chartData.add(new CharDataDTO(category, expenses));
                }
            } catch (Exception e) {
                LOGGER.debug("Error processing income/expense item: {}", e.getMessage());
            }
        }

        return new ChartDataResponseDTO(
                "Gastos por Categoría",
                "Distribución de gastos por categoría durante el período seleccionado",
                "pie",
                chartData,
                "Categorías",
                "Gastos ($)"
        );
    }

    private ChartDataResponseDTO generateTransactionChart(Object data) {
        if (!(data instanceof List<?> list)) {
            return null;
        }

        Map<String, Double> categoryTotals = new HashMap<>();
        
        for (Object userProfile : list) {
            try {
                // Extraer transacciones del perfil de usuario
                List<?> profiles = getFieldValue(userProfile, "profiles", List.class, Collections.emptyList());
                
                for (Object profile : profiles) {
                    List<?> transactions = getFieldValue(profile, "transactions", List.class, Collections.emptyList());
                    
                    for (Object transaction : transactions) {
                        Double amount = getFieldValue(transaction, "amount", Double.class, 0.0);
                        if (amount == null) {
                            Object amountObj = getFieldValue(transaction, "amount", Object.class, null);
                            if (amountObj != null) {
                                amount = Double.parseDouble(amountObj.toString());
                            } else {
                                continue;
                            }
                        }
                        
                        Object description = getFieldValue(transaction, "description", Object.class, null);
                        String category = "Otros";
                        
                        if (description != null) {
                            category = getFieldValue(description, "description", String.class, "Otros");
                        }
                        
                        categoryTotals.merge(category, Math.abs(amount), Double::sum);
                    }
                }
            } catch (Exception e) {
                LOGGER.debug("Error processing transaction data: {}", e.getMessage());
            }
        }

        List<CharDataDTO> chartData = categoryTotals.entrySet().stream()
                .map(entry -> new CharDataDTO(entry.getKey(), entry.getValue()))
                .sorted((a, b) -> Double.compare(b.getValue(), a.getValue()))
                .limit(10) // Top 10 categorías
                .collect(Collectors.toList());

        return new ChartDataResponseDTO(
                "Transacciones por Categoría",
                "Las 10 principales categorías de transacciones por monto",
                "doughnut",
                chartData,
                "Categorías",
                "Monto ($)"
        );
    }

    private ChartDataResponseDTO generateDebtChart(Object data) {
        if (!(data instanceof List<?> list)) {
            return null;
        }

        List<CharDataDTO> chartData = new ArrayList<>();
        for (Object debt : list) {
            try {
                String debtId = getFieldValue(debt, "id", String.class, "Deuda");
                Double pendingAmount = getFieldValue(debt, "pendingAmount", Double.class, 0.0);
                if (pendingAmount == null) {
                    Object amountObj = getFieldValue(debt, "pendingAmount", Object.class, null);
                    if (amountObj != null) {
                        pendingAmount = Double.parseDouble(amountObj.toString());
                    } else {
                        pendingAmount = 0.0;
                    }
                }
                
                if (pendingAmount > 0) {
                    chartData.add(new CharDataDTO("Deuda " + debtId, pendingAmount));
                }
            } catch (Exception e) {
                LOGGER.debug("Error processing debt item: {}", e.getMessage());
            }
        }

        return new ChartDataResponseDTO(
                "Distribución de Deudas",
                "Montos pendientes por deuda activa",
                "bar",
                chartData,
                "Deudas",
                "Monto Pendiente ($)"
        );
    }

    private ChartDataResponseDTO generateBudgetComparisonChart(Object data) {
        if (!(data instanceof List<?> list)) {
            return null;
        }

        List<CharDataDTO> chartData = new ArrayList<>();
        for (Object budget : list) {
            try {
                String category = getFieldValue(budget, "categoryName", String.class, "N/A");
                Double assigned = getFieldValue(budget, "assignedAmount", Double.class, 0.0);
                Double spent = getFieldValue(budget, "actualSpent", Double.class, 0.0);
                
                if (assigned == null) {
                    Object assignedObj = getFieldValue(budget, "assignedAmount", Object.class, null);
                    if (assignedObj != null) {
                        assigned = Double.parseDouble(assignedObj.toString());
                    } else {
                        assigned = 0.0;
                    }
                }
                
                if (spent == null) {
                    Object spentObj = getFieldValue(budget, "actualSpent", Object.class, null);
                    if (spentObj != null) {
                        spent = Double.parseDouble(spentObj.toString());
                    } else {
                        spent = 0.0;
                    }
                }
                
                // Calcular utilización del presupuesto como porcentaje
                double utilization = assigned > 0 ? (spent / assigned) * 100 : 0;
                chartData.add(new CharDataDTO(category, utilization));
            } catch (Exception e) {
                LOGGER.debug("Error processing budget item: {}", e.getMessage());
            }
        }

        return new ChartDataResponseDTO(
                "Utilización del Presupuesto",
                "Porcentaje de utilización del presupuesto por categoría",
                "horizontalBar",
                chartData,
                "Categorías",
                "Utilización (%)"
        );
    }

    /**
     * Método auxiliar para extraer valores de campos usando reflexión de forma segura
     */
    @SuppressWarnings("unchecked")
    private <T> T getFieldValue(Object object, String fieldName, Class<T> expectedType, T defaultValue) {
        try {
            Class<?> clazz = object.getClass();
            
            // Intentar primero con el campo directo
            try {
                java.lang.reflect.Field field = clazz.getDeclaredField(fieldName);
                field.setAccessible(true);
                Object value = field.get(object);
                
                if (value != null && expectedType.isAssignableFrom(value.getClass())) {
                    return (T) value;
                } else if (value != null && expectedType == Double.class && value instanceof Number) {
                    return (T) Double.valueOf(((Number) value).doubleValue());
                } else if (value != null && expectedType == String.class) {
                    return (T) value.toString();
                }
            } catch (NoSuchFieldException e) {
                // Intentar con getter method
                String getterName = "get" + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1);
                try {
                    java.lang.reflect.Method getter = clazz.getMethod(getterName);
                    Object value = getter.invoke(object);
                    
                    if (value != null && expectedType.isAssignableFrom(value.getClass())) {
                        return (T) value;
                    } else if (value != null && expectedType == Double.class && value instanceof Number) {
                        return (T) Double.valueOf(((Number) value).doubleValue());
                    } else if (value != null && expectedType == String.class) {
                        return (T) value.toString();
                    }
                } catch (Exception me) {
                    LOGGER.debug("No se pudo acceder al getter '{}': {}", getterName, me.getMessage());
                }
            }
        } catch (Exception e) {
            LOGGER.debug("No se pudo extraer el campo '{}': {}", fieldName, e.getMessage());
        }
        return defaultValue;
    }
}
