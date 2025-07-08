package com.example.back_end.KuentecoChat.service;

import com.example.back_end.KuentecoChat.dto.request.ChatDTO;
import com.example.back_end.KuentecoChat.dto.request.ChatFilesDTO;
import com.example.back_end.KuentecoChat.dto.request.ChatHistoryDTO;
import com.example.back_end.KuentecoChat.dto.request.ChatMultipartDTO;
import com.example.back_end.KuentecoChat.dto.rest.AnalysisResponseDTO;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;

public interface ChatService {
    AnalysisResponseDTO queryAi(ChatDTO request);
    String queryAi(ChatMultipartDTO request);
    String queryAi(ChatFilesDTO request);
    List<ChatHistoryDTO> getHistoryByConversationId(String conversationId);
    List<ChatHistoryDTO> getAllConversationsOfAuthenticatedUser(HttpServletRequest request);
}
