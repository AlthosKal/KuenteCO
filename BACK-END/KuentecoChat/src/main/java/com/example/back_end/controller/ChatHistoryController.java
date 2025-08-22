package com.example.back_end.controller;

import com.example.back_end.controller.resource.ChatHistoryResource;
import com.example.back_end.dto.request.ChatHistoryDTO;
import com.example.back_end.exception.ApiResponse;
import com.example.back_end.service.ChatService;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/chat/history")
@RequiredArgsConstructor
public class ChatHistoryController implements ChatHistoryResource {

    private static final Logger LOGGER = LoggerFactory.getLogger(ChatHistoryController.class);
    private final ChatService chatService;

    @GetMapping("/user")
    public ResponseEntity<?> getAllUserConversations(HttpServletRequest request) {
        List<ChatHistoryDTO> summaries =
                chatService.getAllConversationsOfAuthenticatedUser(request);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Historial obtenido correctamente", summaries, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/{conversationId}")
    @Override
    public ResponseEntity<?> getHistory(
            @PathVariable String conversationId, HttpServletRequest request) {
        LOGGER.info("Fetching history for conversationId: {}", conversationId);
        List<ChatHistoryDTO> history = chatService.getHistoryByConversationId(conversationId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Historial obtenido correctamente", history, request.getRequestURI()),
                HttpStatus.OK);
    }

    @DeleteMapping("/delete/{conversationId}")
    public ResponseEntity<?> deleteHistory(@PathVariable String conversationId) {
        chatService.removeChatHistoryByConversationId(conversationId);
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
