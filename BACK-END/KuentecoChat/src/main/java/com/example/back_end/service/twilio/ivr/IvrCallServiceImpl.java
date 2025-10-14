package com.example.back_end.service.twilio.ivr;

import com.example.back_end.configuration.twilio.TwilioConfigProperties;
import com.example.back_end.connector.rest.auth.LoginDTO;
import com.example.back_end.dto.request.ChatDTO;
import com.example.back_end.service.auth.AuthenticationService;
import com.example.back_end.service.function.FunctionService;
import com.example.back_end.service.function.list.ConversationIdService;
import com.example.back_end.service.session.SessionManager;
import com.twilio.rest.api.v2010.account.Call;
import com.twilio.twiml.VoiceResponse;
import com.twilio.twiml.voice.Gather;
import com.twilio.twiml.voice.Say;
import com.twilio.type.PhoneNumber;
import java.net.URI;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.client.advisor.PromptChatMemoryAdvisor;
import org.springframework.ai.chat.memory.InMemoryChatMemory;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class IvrCallServiceImpl implements IvrCallService {
    private final ChatModel openaiChatModel;
    private final TwilioConfigProperties twilioConfigProperties;
    private final ConversationIdService conversationIdService;
    private final FunctionService functionService;
    private final SessionManager sessionManager;
    private final AuthenticationService authenticationService;
    // Almacenar memoria y ChatClient por CallSid
    private final Map<String, InMemoryChatMemory> conversationMemories = new ConcurrentHashMap<>();
    private final Map<String, ChatClient> chatClients = new ConcurrentHashMap<>();

    @Value("${twilio.base-url}")
    private String baseUrl;

    public IvrCallServiceImpl(
            @Qualifier(value = "openAiChatModel") ChatModel openaiChatModel,
            FunctionService functionService,
            ConversationIdService conversationIdService,
            TwilioConfigProperties twilioConfigProperties,
            SessionManager sessionManager,
            AuthenticationService authenticationService) {
        this.twilioConfigProperties = twilioConfigProperties;
        this.openaiChatModel = openaiChatModel;
        this.conversationIdService = conversationIdService;
        this.functionService = functionService;
        this.sessionManager = sessionManager;
        this.authenticationService = authenticationService;
    }

    @Override
    public String handleIncomingCall(String callSid, String from) {

        // Inicializar el ChatClient en esta llamada
        getChatClientForCall(callSid);

        VoiceResponse voiceResponse =
                new VoiceResponse.Builder()
                        .say(
                                new Say.Builder(
                                                "Bienvenido, soy tu asistente financiero, Estoy aquí para ayudarte")
                                        .language(Say.Language.ES_MX)
                                        .build())
                        .gather(
                                new Gather.Builder()
                                        .inputs(List.of(Gather.Input.SPEECH))
                                        .speechTimeout("auto")
                                        .timeout(10) // Espera 10 segundos de silencio
                                        .action(baseUrl + "/api/chat/v1/voice/process-speech")
                                        .build())
                        .say(
                                new Say.Builder("No escuché nada. Adiós.")
                                        .language(Say.Language.ES_MX)
                                        .build())
                        .build();
        return voiceResponse.toXml();
    }

    @Override
    public String initiateCall(String toPhoneNumber) {
        log.info("Initiating call to: {}", toPhoneNumber);

        // Formatear el número al formato E.164 si es necesario
        String formattedNumber = formatPhoneNumber(toPhoneNumber);

        Call call =
                Call.creator(
                                new PhoneNumber(formattedNumber), // Número destino
                                new PhoneNumber(
                                        twilioConfigProperties
                                                .getPhoneNumber()), // Tu número Twilio
                                URI.create(
                                        baseUrl + "/api/chat/v1/voice/incoming") // URL del webhook
                                )
                        .setMachineDetection("DetectMessageEnd") // Detectar contestadora
                        .setMachineDetectionTimeout(30)
                        .setStatusCallback(URI.create(baseUrl + "/api/chat/v1/voice/call-ended"))
                        .setStatusCallbackEvent(List.of("completed", "no-answer", "busy", "failed"))
                        .create();

        log.info("Call initiated successfully. CallSid: {}", call.getSid());
        return call.getSid();
    }

    @Override
    public String processSpeech(String speechResult, String callSid) {
        String responseMessage;

        // Verificar si el usuario está autenticado
        if (!sessionManager.isAuthenticated(callSid)) {
            // Intentar extraer credenciales del mensaje de voz
            LoginDTO credentials = authenticationService.extractCredentials(speechResult);

            if (credentials != null) {
                // Intentar autenticar
                responseMessage = authenticationService.authenticateUser(callSid, credentials);
            } else {
                // Solicitar credenciales
                responseMessage = authenticationService.requestCredentials(callSid);
            }
        } else {
            // Usuario autenticado, procesar la consulta normal
            ChatClient chatClient = getChatClientForCall(callSid);
            responseMessage = generateResponse(speechResult, chatClient, callSid);
        }

        VoiceResponse voiceResponse =
                new VoiceResponse.Builder()
                        .say(new Say.Builder(responseMessage).language(Say.Language.ES_MX).build())
                        .gather(
                                new Gather.Builder()
                                        .inputs(List.of(Gather.Input.SPEECH))
                                        .speechTimeout("auto")
                                        .action(baseUrl + "/api/chat/v1/voice/process-speech")
                                        .build())
                        .build();
        return voiceResponse.toXml();
    }

    @Override
    public void cleanupCall(String callSid) {
        log.info("Cleaning up conversation memory for CallSid: {}", callSid);

        InMemoryChatMemory memory = conversationMemories.remove(callSid);
        ChatClient client = chatClients.remove(callSid);
        sessionManager.cleanupSession(callSid);

        if (memory != null || client != null) {
            log.info("Successfully cleaned up resources for CallSid: {}", callSid);
        } else {
            log.warn("No resources found to cleanup for CallSid: {}", callSid);
        }
    }

    // Obtener o crear ChatClient para una conversación específica
    private ChatClient getChatClientForCall(String callSid) {
        return chatClients.computeIfAbsent(
                callSid,
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

    private String generateResponse(String userInput, ChatClient chatClient, String sessionId) {
        Prompt prompt = functionService.getPrompt(userInput);
        log.info("User input: {}", userInput);

        // Obtener el token de la sesión
        SessionManager.Session session = sessionManager.getSession(sessionId);
        String token = session != null ? session.getToken() : null;

        ChatDTO dto = new ChatDTO();
        if (dto.needsConversationId()) {
            dto.setConversationId(conversationIdService.generateConversationId());
        }
        dto.setPrompt(prompt.toString());
        String detectedFunction = functionService.detectFunctionFromPrompt(userInput);
        Object functionData = functionService.getFunctionData(detectedFunction, dto, token);

        // Crear contexto con información disponible
        String contextualPrompt =
                functionService.createContextualPrompt(
                        dto.getPrompt(), detectedFunction, functionData);
        return chatClient.prompt().user(contextualPrompt).call().content();
    }

    private String formatPhoneNumber(String phoneNumber) {
        // Eliminar espacios y caracteres especiales
        String clean = phoneNumber.replaceAll("[^0-9+]", "");

        // Si ya tiene +, retornar
        if (clean.startsWith("+")) {
            return clean;
        }

        // Para Colombia: si no tiene código de país, agregarlo
        if (!clean.startsWith("57") && clean.length() == 10) {
            clean = "57" + clean;
        }

        // Agregar el + si no lo tiene
        if (!clean.startsWith("+")) {
            clean = "+" + clean;
        }

        log.info("Formatted phone number: {} -> {}", phoneNumber, clean);
        return clean;
    }
}
