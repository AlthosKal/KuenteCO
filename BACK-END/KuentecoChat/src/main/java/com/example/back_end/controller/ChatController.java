package com.example.back_end.controller;

import com.example.back_end.controller.resource.ChatResource;
import com.example.back_end.dto.request.ChatDTO;
import com.example.back_end.dto.request.ChatFilesDTO;
import com.example.back_end.dto.request.ChatMultipartDTO;
import com.example.back_end.dto.response.DynamicAnalysisResponseDTO;
import com.example.back_end.dto.response.StringChatResponseDTO;
import com.example.back_end.exception.ApiResponse;
import com.example.back_end.service.ChatService;
import com.example.back_end.service.ReportGenerationService;
import com.example.back_end.service.functions.ConversationIdService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1")
@RequiredArgsConstructor
public class ChatController implements ChatResource {
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatController.class);

    private final ChatService chatService;
    private final ConversationIdService conversationIdService;
    private final ReportGenerationService reportGenerationService;

    @Override
    @PostMapping(value = "/chat")
    public ResponseEntity<?> askAi(@RequestBody @Valid ChatDTO dto, HttpServletRequest request) {
        if (dto.needsConversationId()) {
            dto.setConversationId(conversationIdService.generateConversationId());
        }

        LOGGER.info("Processing the prompt with {}", dto);
        DynamicAnalysisResponseDTO response = chatService.queryAi(dto, request);

        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Respuesta generada correctamente", response, request.getRequestURI()),
                HttpStatus.OK);
    }

    @Override
    @PostMapping(value = "/chat-with-url")
    public ResponseEntity<?> askAiWithUrl(
            @RequestBody @Valid ChatFilesDTO dto, HttpServletRequest request) {
        if (dto.needsConversationId()) {
            dto.setConversationId(conversationIdService.generateConversationId());
            LOGGER.info("Generated conversationId: {}", dto.getConversationId());
        }
        LOGGER.info("Processing the files with {}", dto);
        String aiResponse = chatService.queryAi(dto, request);

        StringChatResponseDTO response =
                new StringChatResponseDTO(dto.getConversationId(), aiResponse, null);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Respuesta generada correctamente", response, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping(value = "/chat-with-file")
    @Override
    public ResponseEntity<?> askAiWithFile(
            @ModelAttribute @Valid ChatMultipartDTO dto, HttpServletRequest request) {
        if (dto.needsConversationId()) {
            dto.setConversationId(conversationIdService.generateConversationId());
            LOGGER.info("Generated conversationId: {}", dto.getConversationId());
        }
        LOGGER.info("Processing the file with {}", dto);
        String aiResponse = chatService.queryAi(dto, request);

        StringChatResponseDTO response =
                new StringChatResponseDTO(dto.getConversationId(), aiResponse, null);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Respuesta generada correctamente", response, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/reports/download/{reportId}")
    public ResponseEntity<?> downloadReport(@PathVariable String reportId) {
        return reportGenerationService.downloadReport(reportId);
    }
}
