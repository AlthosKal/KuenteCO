package com.example.back_end.KuentecoChat.mapper;

import com.example.back_end.KuentecoChat.dto.request.ChatHistoryDTO;
import com.example.back_end.KuentecoChat.entity.ChatHistory;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ChatHistoryMapper {

    ChatHistory toEntity(ChatHistoryDTO chatHistoryDTO);

    ChatHistoryDTO toDTO(ChatHistory chatHistory);

}
