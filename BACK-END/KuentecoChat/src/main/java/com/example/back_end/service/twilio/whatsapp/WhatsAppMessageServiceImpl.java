package com.example.back_end.service.twilio.whatsapp;

import com.example.back_end.configuration.twilio.TwilioConfigProperties;
import com.example.back_end.connector.rest.auth.LoginDTO;
import com.example.back_end.dto.request.ChatDTO;
import com.example.back_end.service.auth.AuthenticationService;
import com.example.back_end.service.function.FunctionService;
import com.example.back_end.service.function.list.ConversationIdService;
import com.example.back_end.service.session.SessionManager;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import java.time.LocalDateTime;
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
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class WhatsAppMessageServiceImpl implements WhatsAppMessageService {
    private final ChatModel openaiChatModel;
    private final FunctionService functionService;
    private final ConversationIdService conversationIdService;
    private final TwilioConfigProperties twilioConfigProperties;
    private final SessionManager sessionManager;
    private final AuthenticationService authenticationService;

    // Almacenar memoria y ChatClient por número de WhatsApp
    private final Map<String, InMemoryChatMemory> conversationMemories = new ConcurrentHashMap<>();
    private final Map<String, ChatClient> chatClients = new ConcurrentHashMap<>();

    // Agregar timestamp de última actividad
    private final Map<String, LocalDateTime> conversationLastActivity = new ConcurrentHashMap<>();

    public WhatsAppMessageServiceImpl(
            @Qualifier(value = "openAiChatModel") ChatModel openaiChatModel,
            FunctionService functionService,
            ConversationIdService conversationIdService,
            TwilioConfigProperties twilioConfigProperties,
            SessionManager sessionManager,
            AuthenticationService authenticationService) {
        this.openaiChatModel = openaiChatModel;
        this.conversationIdService = conversationIdService;
        this.functionService = functionService;
        this.twilioConfigProperties = twilioConfigProperties;
        this.sessionManager = sessionManager;
        this.authenticationService = authenticationService;
    }

    @Override
    public void handleIncomingMessage(String from, String body) {
        // Actualizar ultima actividad
        conversationLastActivity.put(from, LocalDateTime.now());

        String responseMessage;

        // Verificar si el usuario está autenticado
        if (!sessionManager.isAuthenticated(from)) {
            // Intentar extraer credenciales del mensaje
            LoginDTO credentials = authenticationService.extractCredentials(body);

            if (credentials != null) {
                // Intentar autenticar
                responseMessage = authenticationService.authenticateUser(from, credentials);
            } else {
                // Solicitar credenciales
                responseMessage = authenticationService.requestCredentials(from);
            }
        } else {
            // Usuario autenticado, procesar la consulta normal
            ChatClient chatClient = getChatClientForConversation(from);
            responseMessage = generateResponse(body, chatClient, from);
        }

        // Enviar respuesta por WhatsApp
        sendWhatsAppMessage(from, responseMessage);
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
                                sessionManager.cleanupSession(entry.getKey());
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
            Message twilioMessage =
                    Message.creator(
                                    new PhoneNumber(userPhoneNumber), // To: usuario que recibirá la
                                    // respuesta
                                    new PhoneNumber(
                                            twilioConfigProperties
                                                    .getWhatsappNumber()), // From: tu número de
                                    // Twilio
                                    message)
                            .create();

            log.info("Message sent successfully. SID: {}", twilioMessage.getSid());
        } catch (Exception e) {
            log.error("Error sending WhatsApp message to {}: {}", userPhoneNumber, e.getMessage());
            throw e;
        }
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
}
