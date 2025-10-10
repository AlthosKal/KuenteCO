package com.example.back_end.service;

import com.example.back_end.configuration.twilio.TwilioConfigProperties;
import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.service.functions.IncomesAndExpensesByPeriodFunction;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.client.advisor.PromptChatMemoryAdvisor;
import org.springframework.ai.chat.memory.InMemoryChatMemory;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

@Slf4j
@Service
public class WhatsAppMessageServiceImpl implements WhatsAppMessageService {
    private final ChatModel openaiChatModel;
    private final KuentecoAppConnector kuentecoAppConnector;
    private final TwilioConfigProperties twilioConfigProperties;

    // Almacenar memoria y ChatClient por número de WhatsApp
    private final Map<String, InMemoryChatMemory> conversationMemories = new ConcurrentHashMap<>();
    private final Map<String, ChatClient> chatClients = new ConcurrentHashMap<>();

    // Agregar timestamp de última actividad
    private final Map<String, LocalDateTime> conversationLastActivity = new ConcurrentHashMap<>();

    public WhatsAppMessageServiceImpl(
            @Qualifier(value = "openAiChatModel") ChatModel openaiChatModel,
            KuentecoAppConnector kuentecoAppConnector,
            TwilioConfigProperties twilioConfigProperties) {
        this.openaiChatModel = openaiChatModel;
        this.kuentecoAppConnector = kuentecoAppConnector;
        this.twilioConfigProperties = twilioConfigProperties;
    }

    @Override
    public void handleIncomingMessage(String from, String body) {
        // Actualizar ultima actividad
        conversationLastActivity.put(from, LocalDateTime.now());
        // Inicializar el ChatClient en esta llamada
        ChatClient chatClient = getChatClientForConversation(from);
        // El LLM procesa el mensaje del usuario
        String message = generateResponse(body, chatClient);
        // Enviar respuesta por WhatsApp
        sendWhatsAppMessage(from, message);
    }

    @Override
    public void handleMessageStatus(
            String messageSid,
            String messageStatus,
            String from,
            String to,
            String errorCode,
            String errorMessage) {

        log.info(
                "Message status update - MessageSid: {}, Status: {}, From: {}, To: {}",
                messageSid,
                messageStatus,
                from,
                to);

        switch (messageStatus.toLowerCase()) {
            case "delivered":
                log.info("Message {} successfully delivered", messageSid);
                break;
            case "read":
                log.info("Message {} was read by user", messageSid);
                break;
            case "failed":
            case "undelivered":
                log.error(
                        "Message {} failed - ErrorCode: {}, ErrorMessage: {}",
                        messageSid,
                        errorCode,
                        errorMessage);
                // Aquí podrías implementar lógica de reintento o notificación
                break;
            default:
                log.debug("Message {} status: {}", messageSid, messageStatus);
        }
    }

    @Scheduled(fixedRate = 86400)
    public void cleanupCalls() {
        log.info("Cleaning up conversation memory");
        LocalDateTime cutoffTime = LocalDateTime.now().minusMinutes(30);

        conversationLastActivity
                .entrySet()
                .removeIf(
                        entry -> {
                            if (entry.getValue().isBefore(cutoffTime)) {
                                log.info(
                                        "Cleaning up inactive conversation for: {}",
                                        entry.getKey());
                                conversationMemories.remove(entry.getKey());
                                chatClients.remove(entry.getKey());
                                return true;
                            }
                            return false;
                        });
    }

    // Obtener o crear ChatClient para una conversación específica
    private ChatClient getChatClientForConversation(String from) {
        return chatClients.computeIfAbsent(
                from,
                sid -> {
                    log.info("Creating new ChatClient with memory for CallSid: {}", sid);

                    InMemoryChatMemory memory = new InMemoryChatMemory();
                    conversationMemories.put(sid, memory);

                    return ChatClient.builder(openaiChatModel)
                            .defaultAdvisors(
                                    new PromptChatMemoryAdvisor(memory),
                                    new MessageChatMemoryAdvisor(memory))
                            .build();
                });
    }

    private void sendWhatsAppMessage(String userPhoneNumber, String message) {
        try {
            Message twilioMessage = Message.creator(
                            new PhoneNumber(userPhoneNumber), // To: usuario que recibirá la respuesta
                            new PhoneNumber(twilioConfigProperties.getWhatsappNumber()), // From: tu número de Twilio
                            message)
                    .create();

            log.info("Message sent successfully. SID: {}", twilioMessage.getSid());
        } catch (Exception e) {
            log.error("Error sending WhatsApp message to {}: {}", userPhoneNumber, e.getMessage());
            throw e;
        }
    }

    private String generateResponse(String userInput, ChatClient chatClient) {
        Prompt prompt = getPrompt(userInput);
        log.info("User input: {}", userInput);

        String detectedFunction = detectFunctionFromPrompt(userInput);
        String contextData = "";

        // Solo ejecutar función si se detectó
        if ("IncomesAndExpensesByPeriod".equals(detectedFunction)) {
            Object functionResult = executeIncomesAndExpensesFunction(prompt.toString());
            if (functionResult != null) {
                contextData = "\n\nDatos financieros obtenidos: " + functionResult;
            }
        }

        String finalPrompt = prompt.getContents() + contextData;
        return chatClient.prompt().user(finalPrompt).call().content();
    }

    private Prompt getPrompt(String userInput) {
        PromptTemplate promptTemplate = new PromptTemplate(loadPromptFromClasspath());

        Map<String, Object> params = Map.of("prompt", userInput);
        return promptTemplate.create(params);
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

    private KuentecoAppConnector getConnector() {
        return this.kuentecoAppConnector;
    }

    private Object executeIncomesAndExpensesFunction(String prompt) {
        try {
            Map<String, String> params = extractDateParameters(prompt);
            IncomesAndExpensesByPeriodFunction.Request functionRequest =
                    new IncomesAndExpensesByPeriodFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            IncomesAndExpensesByPeriodFunction function =
                    new IncomesAndExpensesByPeriodFunction(getConnector());
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing incomes and expenses function", e);
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

    private String detectFunctionFromPrompt(String prompt) {
        String lowerPrompt = prompt.toLowerCase();
        String detectedFunction = "general";
        if (lowerPrompt.contains("ingreso") && lowerPrompt.contains("gasto")) {
            detectedFunction = "IncomesAndExpensesByPeriod";
            log.info("Detected function '{}' from prompt: '{}'", detectedFunction, prompt);
            return detectedFunction;
        }
        return detectedFunction;
    }
}
