package com.example.back_end.service.chat;

import com.example.back_end.dto.request.*;
import com.example.back_end.dto.response.DynamicAnalysisResponseDTO;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

public interface ChatService {
    DynamicAnalysisResponseDTO queryAi(ChatDTO dto, HttpServletRequest request);

    String queryAi(ChatMultipartDTO dto, HttpServletRequest request);

    String queryAi(ChatFilesDTO dto, HttpServletRequest request);

    List<ChatHistoryForConversationDTO> getHistoryByConversationId(String conversationId);

    List<ChatHistoryDTO> getAllConversationsOfAuthenticatedUser(HttpServletRequest request);

    void removeChatHistoryByConversationId(String conversationId);
}
