package com.example.back_end.mapper;

import com.example.back_end.dto.request.ChatHistoryDTO;
import com.example.back_end.entity.ChatHistory;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ChatHistoryMapper {

    ChatHistoryDTO toDTO(ChatHistory chatHistory);
}
