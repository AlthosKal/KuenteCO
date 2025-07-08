package com.example.back_end.KuentecoChat.controller;

import com.example.back_end.KuentecoChat.controller.resource.ChatHistoryResource;
import com.example.back_end.KuentecoChat.dto.request.ChatHistoryDTO;
import com.example.back_end.KuentecoChat.service.ChatService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/chat/history")
@RequiredArgsConstructor
public class ChatHistoryController implements ChatHistoryResource {

    private static final Logger LOGGER = LoggerFactory.getLogger(ChatHistoryController.class);
    private final ChatService chatService;

    @GetMapping("/user")
    public ResponseEntity<List<ChatHistoryDTO>> getAllUserConversations(HttpServletRequest request) {
        List<ChatHistoryDTO> summaries = chatService.getAllConversationsOfAuthenticatedUser(request);
        return ResponseEntity.ok(summaries);
    }


    @GetMapping("/{conversationId}")
    @Override
    public ResponseEntity<List<ChatHistoryDTO>> getHistory(@PathVariable String conversationId) {
        LOGGER.info("Fetching history for conversationId: {}", conversationId);
        List<ChatHistoryDTO> history = chatService.getHistoryByConversationId(conversationId);
        return ResponseEntity.ok(history);
    }
}
