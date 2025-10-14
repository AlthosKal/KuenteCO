package com.example.back_end.service.chat;

import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_CONVERSATION_ID_KEY;
import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_RETRIEVE_SIZE_KEY;

import com.example.back_end.configuration.security.JwtUtil;
import com.example.back_end.dto.request.*;
import com.example.back_end.dto.response.CharDataDTO;
import com.example.back_end.dto.response.DynamicAnalysisResponseDTO;
import com.example.back_end.dto.response.StringChatResponseDTO;
import com.example.back_end.dto.response.ai.BaseDynamicResponseDTO;
import com.example.back_end.dto.response.ai.ChartDataResponseDTO;
import com.example.back_end.entity.ChatHistory;
import com.example.back_end.enums.ApiError;
import com.example.back_end.enums.Model;
import com.example.back_end.exception.AiProfileException;
import com.example.back_end.mapper.ChatHistoryForConversationMapper;
import com.example.back_end.mapper.ChatHistoryMapper;
import com.example.back_end.repository.AiHistoryRepository;
import com.example.back_end.service.function.FunctionService;
import com.example.back_end.service.report.ReportGenerationService;
import com.example.back_end.service.report.ResponseTypeDetectorService;
import com.example.back_end.util.KuentecoChatUtil;
import jakarta.servlet.http.HttpServletRequest;
import java.util.*;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.client.advisor.PromptChatMemoryAdvisor;
import org.springframework.ai.chat.memory.InMemoryChatMemory;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class ChatServiceImpl implements ChatService {
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatServiceImpl.class);
    private final ChatClient openaiChatClient;
    private final AiHistoryRepository repository;
    private final ChatHistoryForConversationMapper chatHistoryForConversationMapper;
    private final ChatHistoryMapper chatHistoryMapper;
    private final ResponseTypeDetectorService responseTypeDetector;
    private final JwtUtil jwtUtil;
    private final ReportGenerationService reportGenerationService;
    private final FunctionService functionService;

    public ChatServiceImpl(
            @Qualifier(value = "openAiChatModel") ChatModel openaiChatClient,
            JwtUtil jwtUtil,
            AiHistoryRepository repository,
            ChatHistoryForConversationMapper chatHistoryForConversationMapper,
            ChatHistoryMapper chatHistoryMapper,
            ResponseTypeDetectorService responseTypeDetectorService,
            FunctionService functionService,
            ReportGenerationService reportGenerationService) {

        InMemoryChatMemory memory = new InMemoryChatMemory();
        this.openaiChatClient =
                ChatClient.builder(openaiChatClient)
                        .defaultAdvisors(
                                new PromptChatMemoryAdvisor(memory),
                                new MessageChatMemoryAdvisor(memory))
                        .build();

        this.jwtUtil = jwtUtil;
        this.repository = repository;
        this.chatHistoryForConversationMapper = chatHistoryForConversationMapper;
        this.responseTypeDetector = responseTypeDetectorService;
        this.functionService = functionService;
        this.reportGenerationService = reportGenerationService;
        this.chatHistoryMapper = chatHistoryMapper;
    }

    @Override
    @Cacheable(value = "chats", key = "#dto.prompt") // Temporarily disabled
    // to prevent stale responses
    public DynamicAnalysisResponseDTO queryAi(ChatDTO dto, HttpServletRequest request) {
        try {
            String token = jwtUtil.resolveToken(request);
            String email = jwtUtil.extractEmail(token);
            // Detectar qué función se va a ejecutar basándose en el prompt
            String detectedFunction = functionService.detectFunctionFromPrompt(dto.getPrompt());

            // Obtener datos de la función ejecutada ANTES de llamar al AI
            Object functionData = functionService.getFunctionData(detectedFunction, dto);

            // Crear contexto con información disponible
            String contextualPrompt =
                    functionService.createContextualPrompt(
                            dto.getPrompt(), detectedFunction, functionData);

            // Ejecutar la función con el contexto mejorado
            String response =
                    openaiChatClient
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
            LOGGER.error(
                    "Error generating dynamic response with model {}: {}",
                    Model.OPENAI,
                    e.getMessage(),
                    e);
            throw handleChatException(e, dto);
        }
    }

    public String queryAi(ChatMultipartDTO dto, HttpServletRequest request) {
        try {
            String fileContent = KuentecoChatUtil.convertFileToString(dto.getFile());
            return askToAI(dto, fileContent, request);
        } catch (Exception e) {
            LOGGER.error("Error processing file upload: {}", e.getMessage(), e);
            if (dto.getFile() == null || dto.getFile().isEmpty()) {
                return handleFileException(new IllegalArgumentException("No file provided"));
            }
            return handleFileException(e);
        }
    }

    public String queryAi(ChatFilesDTO dto, HttpServletRequest request) {
        try {
            String fileContent = KuentecoChatUtil.convertFilesToString(dto.getFiles());
            return askToAI(dto, fileContent, request);
        } catch (Exception e) {
            LOGGER.error("Error processing files from URLs: {}", e.getMessage(), e);
            if (dto.getFiles() == null || dto.getFiles().length == 0) {
                return handleFileException(new IllegalArgumentException("No files provided"));
            }
            return handleFileException(e);
        }
    }

    public List<ChatHistoryForConversationDTO> getHistoryByConversationId(String conversationId) {
        return repository.findByConversationId(conversationId).stream()
                .map(chatHistoryForConversationMapper::toDTO)
                .toList();
    }

    @Override
    public List<ChatHistoryDTO> getAllConversationsOfAuthenticatedUser(HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        String email = jwtUtil.extractEmail(token);

        List<ChatHistory> allHistory = repository.findByEmail(email);

        // Agrupa por conversationId y obtiene el PRIMER mensaje de cada conversación (mensaje
        // inicial)
        Map<String, Optional<ChatHistory>> firstByConversation =
                allHistory.stream()
                        .collect(
                                Collectors.groupingBy(
                                        ChatHistory::getConversationId,
                                        Collectors.minBy(
                                                Comparator.comparing(ChatHistory::getDate))));

        return firstByConversation.values().stream()
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
        Prompt prompt = functionService.getPrompt(dto, fileContent);
        LOGGER.info(prompt.getInstructions().toString());

        String response =
                openaiChatClient
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

    /**
     * Maneja excepciones de manera inteligente para proporcionar errores más específicos
     *
     * @param e La excepción original
     * @param dto El DTO de la request para contexto
     * @return AiProfileException apropiada según el tipo de error
     */
    private AiProfileException handleChatException(Exception e, ChatDTO dto) {
        // Desenrollar la cadena de excepciones para encontrar la causa raíz
        Throwable rootCause = e;
        while (rootCause.getCause() != null && rootCause.getCause() != rootCause) {
            rootCause = rootCause.getCause();
        }

        // Manejo específico de timeouts
        if (rootCause instanceof io.netty.handler.timeout.ReadTimeoutException) {
            LOGGER.warn(
                    "Timeout calling {} model for prompt: {}",
                    Model.OPENAI.name(),
                    dto.getPrompt());
            return new AiProfileException(
                    ApiError.AI_PROVIDER_TIMEOUT.getHttpStatus(),
                    ApiError.AI_PROVIDER_TIMEOUT.getMessage(),
                    List.of(
                            "The " + Model.OPENAI.name() + " model did not respond in time",
                            "This often happens with complex prompts or report generation",
                            "Try again or switch to a different model",
                            "Consider simplifying your request"));
        }

        // Manejo de errores de conectividad
        if (e instanceof org.springframework.web.client.ResourceAccessException
                || rootCause instanceof java.net.ConnectException
                || rootCause instanceof java.net.UnknownHostException) {
            LOGGER.warn(
                    "Network error calling {} model: {}",
                    Model.OPENAI.name(),
                    rootCause.getMessage());
            return new AiProfileException(
                    ApiError.AI_PROVIDER_UNAVAILABLE.getHttpStatus(),
                    ApiError.AI_PROVIDER_UNAVAILABLE.getMessage(),
                    List.of(
                            "Cannot connect to " + Model.OPENAI.name() + " provider",
                            "Check your internet connection",
                            "The AI service may be temporarily unavailable",
                            "Try again in a few minutes"));
        }

        // Validación de formato del mensaje
        if (dto.getPrompt() == null || dto.getPrompt().trim().isEmpty()) {
            LOGGER.warn("Empty or null prompt provided");
            return new AiProfileException(
                    ApiError.BAD_FORMAT.getHttpStatus(),
                    ApiError.BAD_FORMAT.getMessage(),
                    List.of("The message cannot be empty", "Please provide a valid prompt"));
        }

        // Errores de validación de Spring
        if (e instanceof org.springframework.web.bind.MethodArgumentNotValidException) {
            LOGGER.warn("Validation error in request: {}", e.getMessage());
            return new AiProfileException(ApiError.VALIDATION_ERROR);
        }

        // Error genérico - no sabemos exactamente qué pasó
        LOGGER.error(
                "Unexpected error processing chat request with {} model", Model.OPENAI.name(), e);
        return new AiProfileException(
                ApiError.INTERNAL_ERROR.getHttpStatus(),
                ApiError.INTERNAL_ERROR.getMessage(),
                List.of(
                        "An unexpected error occurred while processing your request",
                        "Error type: " + e.getClass().getSimpleName(),
                        "Please try again or contact support if the problem persists"));
    }

    /**
     * Maneja excepciones relacionadas con el procesamiento de archivos
     *
     * @param e La excepción original
     * @return String con mensaje de error (en lugar de lanzar excepción)
     */
    private String handleFileException(Exception e) {
        if (e instanceof IllegalArgumentException && e.getMessage().contains("No file")) {
            throw new AiProfileException(
                    ApiError.BAD_FORMAT.getHttpStatus(),
                    "Invalid file upload",
                    List.of("No file was provided", "Please select a file to upload"));
        }

        if (e instanceof java.io.IOException) {
            throw new AiProfileException(
                    ApiError.BAD_FORMAT.getHttpStatus(),
                    "File processing error",
                    List.of(
                            "Could not read the uploaded file",
                            "File may be corrupted or in an unsupported format",
                            "Please try uploading a different file"));
        }

        throw new AiProfileException(
                ApiError.INTERNAL_ERROR.getHttpStatus(),
                "Error processing file",
                List.of(
                        "An unexpected error occurred while processing your file",
                        "Please try again or contact support"));
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

            return switch (functionName) {
                case "BalanceOverTime" -> generateBalanceChart(functionData);
                case "IncomesAndExpensesByPeriod" -> generateIncomeExpenseChart(functionData);
                case "analyzeUserSpendingPatterns", "calculateFinancialHealthScore" ->
                        generateTransactionChart(functionData);
                case "analyzeDebtRisk" -> generateDebtChart(functionData);
                case "compareFinancialPeriods" -> generateBudgetComparisonChart(functionData);
                default -> null;
            };
        } catch (Exception e) {
            LOGGER.warn(
                    "Error generating chart data for function {}: {}",
                    functionName,
                    e.getMessage());
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
                "Balance ($)");
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
                "Gastos ($)");
    }

    private ChartDataResponseDTO generateTransactionChart(Object data) {
        if (!(data instanceof List<?> list)) {
            return null;
        }

        Map<String, Double> categoryTotals = new HashMap<>();

        for (Object userProfile : list) {
            try {
                // Extraer transacciones del perfil de usuario
                List<?> profiles =
                        getFieldValue(userProfile, "profiles", List.class, Collections.emptyList());

                for (Object profile : profiles) {
                    List<?> transactions =
                            getFieldValue(
                                    profile, "transactions", List.class, Collections.emptyList());

                    for (Object transaction : transactions) {
                        Double amount = getFieldValue(transaction, "amount", Double.class, 0.0);
                        if (amount == null) {
                            Object amountObj =
                                    getFieldValue(transaction, "amount", Object.class, null);
                            if (amountObj != null) {
                                amount = Double.parseDouble(amountObj.toString());
                            } else {
                                continue;
                            }
                        }

                        Object description =
                                getFieldValue(transaction, "description", Object.class, null);
                        String category = "Otros";

                        if (description != null) {
                            category =
                                    getFieldValue(
                                            description, "description", String.class, "Otros");
                        }

                        categoryTotals.merge(category, Math.abs(amount), Double::sum);
                    }
                }
            } catch (Exception e) {
                LOGGER.debug("Error processing transaction data: {}", e.getMessage());
            }
        }

        List<CharDataDTO> chartData =
                categoryTotals.entrySet().stream()
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
                "Monto ($)");
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
                "Monto Pendiente ($)");
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
                    Object assignedObj =
                            getFieldValue(budget, "assignedAmount", Object.class, null);
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
                "Utilización (%)");
    }

    /** Método auxiliar para extraer valores de campos usando reflexión de forma segura */
    @SuppressWarnings("unchecked")
    private <T> T getFieldValue(
            Object object, String fieldName, Class<T> expectedType, T defaultValue) {
        try {
            Class<?> clazz = object.getClass();

            // Intentar primero con el campo directo
            try {
                java.lang.reflect.Field field = clazz.getDeclaredField(fieldName);
                field.setAccessible(true);
                Object value = field.get(object);

                if (value != null && expectedType.isAssignableFrom(value.getClass())) {
                    return (T) value;
                } else if (expectedType == Double.class && value instanceof Number) {
                    return (T) Double.valueOf(((Number) value).doubleValue());
                } else if (value != null && expectedType == String.class) {
                    return (T) value.toString();
                }
            } catch (NoSuchFieldException e) {
                // Intentar con getter method
                String getterName =
                        "get" + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1);
                try {
                    java.lang.reflect.Method getter = clazz.getMethod(getterName);
                    Object value = getter.invoke(object);

                    if (value != null && expectedType.isAssignableFrom(value.getClass())) {
                        return (T) value;
                    } else if (expectedType == Double.class && value instanceof Number) {
                        return (T) Double.valueOf(((Number) value).doubleValue());
                    } else if (value != null && expectedType == String.class) {
                        return (T) value.toString();
                    }
                } catch (Exception me) {
                    LOGGER.debug(
                            "No se pudo acceder al getter '{}': {}", getterName, me.getMessage());
                }
            }
        } catch (Exception e) {
            LOGGER.debug("No se pudo extraer el campo '{}': {}", fieldName, e.getMessage());
        }
        return defaultValue;
    }
}
