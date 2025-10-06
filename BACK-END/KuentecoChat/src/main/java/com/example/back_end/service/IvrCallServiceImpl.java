package com.example.back_end.service;

import com.example.back_end.connector.KuentecoAppConnector;
import com.example.back_end.service.functions.IncomesAndExpensesByPeriodFunction;
import com.twilio.twiml.VoiceResponse;
import com.twilio.twiml.voice.Gather;
import com.twilio.twiml.voice.Pause;
import com.twilio.twiml.voice.Say;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

@Service
@Slf4j
public class IvrCallServiceImpl implements IvrCallService {
    private final ChatClient openaiChatClient;
    private final KuentecoAppConnector kuentecoAppConnector;

    private String baseUrl = "https://b1393225130b.ngrok-free.app";

    public IvrCallServiceImpl(
            @Qualifier(value = "openAiChatModel") ChatModel openaiChatClient,
            KuentecoAppConnector kuentecoAppConnector) {
        InMemoryChatMemory memory = new InMemoryChatMemory();
        this.openaiChatClient =
                ChatClient.builder(openaiChatClient)
                        .defaultAdvisors(
                                new PromptChatMemoryAdvisor(memory),
                                new MessageChatMemoryAdvisor(memory))
                        .build();
        this.kuentecoAppConnector = kuentecoAppConnector;
    }

    @Override
    public String handleIncomingCall(String callSid, String from) {
        VoiceResponse voiceResponse =
                new VoiceResponse.Builder()
                        .pause(new Pause.Builder()
                                .length(2)  // Pausa de 2 segundos antes de hablar
                                .build())
                        .say(
                                new Say.Builder(
                                        "Bienvenido, soy tu asistente financiero, ¿En qué puedo ayudarte?")
                                        .language(Say.Language.ES_MX)
                                        .build())
                        .gather(
                                new Gather.Builder()
                                        .inputs(List.of(Gather.Input.SPEECH))
                                        .speechTimeout("auto")
                                        .timeout(10)  // Espera 10 segundos de silencio
                                        .action(baseUrl + "/api/chat/v1/voice/process-speech")
                                        .build())
                        .say(new Say.Builder("No escuché nada. Adiós.")
                                .language(Say.Language.ES_MX)
                                .build())
                        .build();
        return voiceResponse.toXml();
    }

    @Override
    public String processSpeech(String speechResult, String callSid) {
        String llmResponse = generateResponse(speechResult);

        VoiceResponse voiceResponse =
                new VoiceResponse.Builder()
                        .say(new Say.Builder(llmResponse).language(Say.Language.ES_MX).build())
                        .gather(
                                new Gather.Builder()
                                        .inputs(List.of(Gather.Input.SPEECH))
                                        .speechTimeout("auto")
                                        .action(baseUrl + "/api/chat/v1/voice/process-speech")
                                        .build())
                        .build();
        return voiceResponse.toXml();
    }

    private String generateResponse(String userInput) {
        Prompt prompt = getPrompt(userInput);
        log.info(prompt.getInstructions().toString());
        StringBuilder response =
                new StringBuilder()
                        .append(prompt)
                        .append(detectFunctionFromPrompt(prompt.toString()))
                        .append(executeIncomesAndExpensesFunction(prompt.toString()));
        return openaiChatClient.prompt().user(response.toString()).call().content();
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

    private Object executeIncomesAndExpensesFunction(String request) {
        try {
            Map<String, String> params = extractDateParameters(request);
            IncomesAndExpensesByPeriodFunction.Request functionRequest =
                    new IncomesAndExpensesByPeriodFunction.Request(
                            params.get("from"), params.get("to"), params.get("kind"));

            IncomesAndExpensesByPeriodFunction function =
                    new IncomesAndExpensesByPeriodFunction(kuentecoAppConnector);
            var response = function.apply(functionRequest);
            return response.getData();
        } catch (Exception e) {
            log.error("Error executing incomes and expenses function", e);
            return null;
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
