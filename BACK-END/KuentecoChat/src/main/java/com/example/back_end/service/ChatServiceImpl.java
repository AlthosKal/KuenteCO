package com.example.back_end.service;

import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_CONVERSATION_ID_KEY;
import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_RETRIEVE_SIZE_KEY;

import com.example.back_end.configuration.security.JwtUtil;
import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.dto.request.ChatDTO;
import com.example.back_end.dto.request.ChatFilesDTO;
import com.example.back_end.dto.request.ChatHistoryDTO;
import com.example.back_end.dto.request.ChatMultipartDTO;
import com.example.back_end.dto.response.DynamicAnalysisResponseDTO;
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

    public ChatServiceImpl(
            @Qualifier(value = "openAiChatModel") ChatModel deepseekChatClient,
            @Qualifier(value = "openAiChatModel") ChatModel openaiChatClient,
            JwtUtil jwtUtil,
            AiHistoryRepository repository,
            ChatHistoryMapper chatHistoryMapper,
            ResponseTypeDetectorService responseTypeDetectorService,
            KuentecoAppConnector kuentecoAppConnector) {

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
    }

    @Override
    @Cacheable(value = "chats", key = "#request.model + '-' + #request.prompt")
    public DynamicAnalysisResponseDTO queryAi(ChatDTO dto, HttpServletRequest request) {
        try {
            String token = jwtUtil.resolveToken(request);
            String email = jwtUtil.extractEmail(token);
            // Detectar qué función se va a ejecutar basándose en el prompt
            String detectedFunction = detectFunctionFromPrompt(dto.getPrompt());

            // Ejecutar la función original
            String response =
                    getChatClient(dto.getModel())
                            .prompt()
                            .user(dto.getPrompt())
                            .advisors(
                                    a ->
                                            a.param(
                                                            CHAT_MEMORY_CONVERSATION_ID_KEY,
                                                            dto.getConversationId())
                                                    .param(CHAT_MEMORY_RETRIEVE_SIZE_KEY, 100))
                            .call()
                            .content();

            // Obtener datos de la función ejecutada
            Object functionData = getFunctionData(detectedFunction, dto);

            // Crear respuesta dinámica
            BaseDynamicResponseDTO dynamicResponse =
                    responseTypeDetector.detectAndCreateResponse(
                            dto.getPrompt(), detectedFunction, functionData);

            // Guardar historial si es necesario
            if (Objects.nonNull(dto.getConversationId())) {
                repository.save(
                        new ChatHistory(dto.getConversationId(), dto.getPrompt(), response, email));
            }

            return new DynamicAnalysisResponseDTO(dto.getConversationId(), dynamicResponse);

        } catch (Exception e) {
            LOGGER.error("Error generating dynamic response", e);
            throw new AiProfileException(ApiError.BAD_FORMAT);
        }
    }

    // Método auxiliar para detectar función desde el prompt
    private String detectFunctionFromPrompt(String prompt) {
        String lowerPrompt = prompt.toLowerCase();

        if (lowerPrompt.contains("balance") || lowerPrompt.contains("saldo")) {
            return "BalanceOverTime";
        } else if (lowerPrompt.contains("deuda") || lowerPrompt.contains("debt")) {
            return "analyzeDebtRisk";
        } else if (lowerPrompt.contains("gasto") || lowerPrompt.contains("patrón")) {
            return "analyzeUserSpendingPatterns";
        } else if (lowerPrompt.contains("salud financiera") || lowerPrompt.contains("score")) {
            return "calculateFinancialHealthScore";
        } else if (lowerPrompt.contains("ingreso") && lowerPrompt.contains("gasto")) {
            return "IncomesAndExpensesByPeriod";
        } else if (lowerPrompt.contains("proyección") || lowerPrompt.contains("projection")) {
            return "projectFinancialBalance";
        } else if (lowerPrompt.contains("reducir gastos") || lowerPrompt.contains("expense reduction")) {
            return "suggestExpenseReductions";
        } else if (lowerPrompt.contains("comparar") || lowerPrompt.contains("compare")) {
            return "compareFinancialPeriods";
        } else if (lowerPrompt.contains("reporte") || lowerPrompt.contains("statement")) {
            return "financialStatement";
        }

        return "general";
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
            Map<String, String> params = extractDateParameters(request.getPrompt());
            BalanceOverTimeFunction.Request functionRequest = new BalanceOverTimeFunction.Request(
                    params.get("from"),
                    params.get("to"),
                    params.get("kind")
            );

            BalanceOverTimeFunction function = new BalanceOverTimeFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            LOGGER.error("Error executing balance function", e);
            return null;
        }
    }

    private Object executeDebtAnalysisFunction(ChatDTO request) {
        try {
            Map<String, String> params = extractDateParameters(request.getPrompt());
            AnalyzeDebtRiskFunction.Request functionRequest = new AnalyzeDebtRiskFunction.Request(
                    params.get("from"),
                    params.get("to"),
                    params.get("kind")
            );

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
            AnalyzeUserSpendingPatternsFunction.Request functionRequest = new AnalyzeUserSpendingPatternsFunction.Request(
                    params.get("from"),
                    params.get("to")
            );

            AnalyzeUserSpendingPatternsFunction function = new AnalyzeUserSpendingPatternsFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
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
                            params.get("from"),
                            params.get("to")
                    );

            CalculateFinancialHealthScoreWithTransactionsFunction function =
                    new CalculateFinancialHealthScoreWithTransactionsFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
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
                            params.get("from"),
                            params.get("to"),
                            params.get("kind")
                    );

            IncomesAndExpensesByPeriodFunction function = new IncomesAndExpensesByPeriodFunction(getConnector());
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
                            params.get("from"),
                            params.get("to"),
                            params.get("kind")
                    );

            ProjectFinancialBalanceFunction function = new ProjectFinancialBalanceFunction(getConnector());
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
                            params.get("from"),
                            params.get("to"),
                            params.get("kind")
                    );

            SuggestExpenseReductionsFunction function = new SuggestExpenseReductionsFunction(getConnector());
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
                            params.get("from"),
                            params.get("to"),
                            params.get("kind")
                    );

            CompareFinancialPeriodsFunction function = new CompareFinancialPeriodsFunction(getConnector());
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
                            params.get("from"),
                            params.get("to"),
                            params.get("kind")
                    );

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
        Pattern periodPattern = Pattern.compile("(\\d+)\\s*(día|días|semana|semanas|mes|meses|año|años)");

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
}
