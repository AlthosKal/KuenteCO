package com.example.back_end.mapper;

import com.example.back_end.dto.request.ChatHistoryForConversationDTO;
import com.example.back_end.entity.ChatHistory;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ChatHistoryForConversationMapper {

    ChatHistoryForConversationDTO toDTO(ChatHistory chatHistory);
}
