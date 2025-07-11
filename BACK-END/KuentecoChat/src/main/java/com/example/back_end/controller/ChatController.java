package com.example.back_end.controller;

import com.example.back_end.controller.resource.ChatResource;
import com.example.back_end.dto.request.ChatDTO;
import com.example.back_end.dto.request.ChatFilesDTO;
import com.example.back_end.dto.request.ChatMultipartDTO;
import com.example.back_end.dto.response.ChatResponseDTO;
import com.example.back_end.dto.response.DynamicAnalysisResponseDTO;
import com.example.back_end.dto.response.StringChatResponseDTO;
import com.example.back_end.service.ChatService;
import com.example.back_end.service.functions.ConversationIdService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1")
@RequiredArgsConstructor
public class ChatController implements ChatResource {
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatController.class);

    private final ChatService chatService;
    private final ConversationIdService conversationIdService;

    @Override
    @PostMapping(value = "/chat")
    public ResponseEntity<ChatResponseDTO> askAi(@RequestBody @Valid ChatDTO dto,  HttpServletRequest request) {
        if (dto.needsConversationId()) {
            dto.setConversationId(conversationIdService.generateConversationId());
            LOGGER.info("Generated conversationId: {}", dto.getConversationId());
        }

        LOGGER.info("Processing the prompt with {}", dto);
        DynamicAnalysisResponseDTO analysis = chatService.queryAi(dto,request);

        ChatResponseDTO response = new ChatResponseDTO(dto.getConversationId(), analysis);
        return ResponseEntity.ok().body(response);
    }

    @Override
    @PostMapping(value = "/chat-with-url")
    public ResponseEntity<StringChatResponseDTO> askAiWithUrl(
            @RequestBody @Valid ChatFilesDTO dto, HttpServletRequest request) {
        if (dto.needsConversationId()) {
            dto.setConversationId(conversationIdService.generateConversationId());
            LOGGER.info("Generated conversationId: {}", dto.getConversationId());
        }
        LOGGER.info("Processing the files with {}", dto);
        String aiResponse = chatService.queryAi(dto, request);

        StringChatResponseDTO response =
                new StringChatResponseDTO(dto.getConversationId(), aiResponse);
        return ResponseEntity.ok().body(response);
    }

    @PostMapping(value = "/chat-with-file")
    @Override
    public ResponseEntity<StringChatResponseDTO> askAiWithFile(
            @ModelAttribute @Valid ChatMultipartDTO dto, HttpServletRequest request) {
        if (dto.needsConversationId()) {
            dto.setConversationId(conversationIdService.generateConversationId());
            LOGGER.info("Generated conversationId: {}", dto.getConversationId());
        }
        LOGGER.info("Processing the file with {}", dto);
        String aiResponse = chatService.queryAi(dto, request);

        StringChatResponseDTO response =
                new StringChatResponseDTO(dto.getConversationId(), aiResponse);
        return ResponseEntity.ok().body(response);
    }
}
