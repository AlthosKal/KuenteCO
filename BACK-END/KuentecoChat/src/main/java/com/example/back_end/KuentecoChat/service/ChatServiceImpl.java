package com.example.back_end.KuentecoChat.service;

import com.example.back_end.KuentecoChat.configuration.security.JwtUtil;
import com.example.back_end.KuentecoChat.dto.request.ChatDTO;
import com.example.back_end.KuentecoChat.dto.request.ChatFilesDTO;
import com.example.back_end.KuentecoChat.dto.request.ChatHistoryDTO;
import com.example.back_end.KuentecoChat.dto.request.ChatMultipartDTO;
import com.example.back_end.KuentecoChat.dto.rest.AnalysisResponseDTO;
import com.example.back_end.KuentecoChat.entity.ChatHistory;
import com.example.back_end.KuentecoChat.enums.ApiError;
import com.example.back_end.KuentecoChat.enums.Model;
import com.example.back_end.KuentecoChat.exception.AiProfileException;
import com.example.back_end.KuentecoChat.mapper.ChatHistoryMapper;
import com.example.back_end.KuentecoChat.repository.AiHistoryRepository;
import com.example.back_end.KuentecoChat.util.KuentecoChatUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.client.advisor.PromptChatMemoryAdvisor;
import org.springframework.ai.chat.memory.InMemoryChatMemory;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.converter.BeanOutputConverter;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.ai.model.function.FunctionCallback;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_CONVERSATION_ID_KEY;
import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_RETRIEVE_SIZE_KEY;

@Service
public class ChatServiceImpl implements ChatService{
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatServiceImpl.class);

    private final ChatClient deepseekChatClient;
    private final ChatClient openaiChatClient;
    private final AiHistoryRepository repository;
    private final ChatHistoryMapper chatHistoryMapper;
    private final FunctionCallback balanceOverTimeFunctionCallback;
    private final FunctionCallback incomesAndExpensesByPeriodFunctionCallback;
    private final JwtUtil jwtUtil;

    public ChatServiceImpl(
            @Qualifier(value = "openAiChatModel") ChatModel deepseekChatClient,
            @Qualifier(value = "openAiChatModel") ChatModel openaiChatClient,
            AiHistoryRepository repository,
            ChatHistoryMapper chatHistoryMapper,
            FunctionCallback balanceOverTimeFunction,
            JwtUtil jwtUtil,
            FunctionCallback incomesAndExpensesByPeriodFunction) {

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
        this.balanceOverTimeFunctionCallback = balanceOverTimeFunction;
        this.incomesAndExpensesByPeriodFunctionCallback = incomesAndExpensesByPeriodFunction;
    }

    @Cacheable(value = "chats", key = "#request.model + '-' + #request.prompt")
    public AnalysisResponseDTO queryAi(ChatDTO request) {
        try {

            BeanOutputConverter<AnalysisResponseDTO> beanOutputConverter =
                    new BeanOutputConverter<>(AnalysisResponseDTO.class);

            String format = beanOutputConverter.getFormat();

            UserMessage userMessage = new UserMessage(
                    request.getPrompt().concat(" with the format: ").concat(format));

            String response =
                    getChatClient(request.getModel())
                            .prompt(
                                    new Prompt(
                                            List.of(userMessage),
                                            OpenAiChatOptions.builder()
                                                    .withFunctions(Set.of(
                                                            balanceOverTimeFunctionCallback.getName(),
                                                            incomesAndExpensesByPeriodFunctionCallback.getName()
                                                    ))
                                                    .build()))
                            .call()
                            .content();

            // Update the interaction history
            if (Objects.nonNull(request.getConversationId())) {
                repository.save(
                        chatHistoryMapper.toEntity(new ChatHistoryDTO(
                                request.getConversationId(), request.getPrompt(), response)));
            }
            return beanOutputConverter.convert(response);

        } catch (Exception e) {
            LOGGER.error("Error invoking OpenAI function", e);
            throw new AiProfileException(ApiError.BAD_FORMAT);
        }
    }

    public String queryAi(ChatMultipartDTO request) {
        try {
            String fileContent = KuentecoChatUtil.convertFileToString(request.getFile());
            return askToAI(request,fileContent);
        } catch (Exception e) {
            throw new AiProfileException(ApiError.BAD_FORMAT);
        }
    }

    public String queryAi(ChatFilesDTO request) {
        try {
            String fileContent = KuentecoChatUtil.convertFilesToString(request.getFiles());
            return askToAI(request, fileContent);
        } catch (Exception e) {
            throw new AiProfileException(ApiError.BAD_FORMAT);
        }
    }

    @Cacheable(value = "history", key = "#conversationId")
    public List<ChatHistoryDTO> getHistoryByConversationId(String conversationId) {
        return repository.findByConversationId(conversationId).stream()
                .map(chatHistoryMapper::toDTO).toList();
    }

    @Override
    public List<ChatHistoryDTO> getAllConversationsOfAuthenticatedUser(HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        String username = jwtUtil.extractEmail(token);

        List<ChatHistory> allHistory = repository.findByUsername(username);

        Map<String, Optional<ChatHistory>> latestByConversation = allHistory.stream()
                .collect(Collectors.groupingBy(
                        ChatHistory::getConversationId,
                        Collectors.maxBy(Comparator.comparing(ChatHistory::getDate))
                ));

        return latestByConversation.values().stream()
                .filter(Optional::isPresent)
                .map(Optional::get)
                .map(chatHistoryMapper::toDTO)
                .sorted(Comparator.comparing(ChatHistoryDTO::getDate).reversed())
                .toList();
    }

    private String askToAI(ChatDTO request, String fileContent) {
        Prompt prompt = getPrompt(request, fileContent);
        LOGGER.info(prompt.getInstructions().toString());

        String response =
                getChatClient(request.getModel())
                        .prompt()
                        .user(prompt.toString())
                        .advisors(
                                a ->
                                        a.param(
                                                        CHAT_MEMORY_CONVERSATION_ID_KEY,
                                                        request.getConversationId())
                                                .param(CHAT_MEMORY_RETRIEVE_SIZE_KEY, 100))
                        .call()
                        .content();

        // Update the interaction history
        if (Objects.nonNull(request.getConversationId())) {
            repository.save(
                    new ChatHistory(
                            request.getConversationId(), request.getPrompt(), response));
        }

        return response;
    }

    private Prompt getPrompt(ChatDTO request, String fileContent) {
        PromptTemplate promptTemplate = new PromptTemplate(loadPromptFromClasspath("ai_prompt_template.txt"));

        Map<String, Object> params =
                Map.of("fileContent", fileContent,"prompt", request.getPrompt());
        return promptTemplate.create(params);
    }

    private String loadPromptFromClasspath(String filename) {
        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream("prompts/" + filename)) {
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
}