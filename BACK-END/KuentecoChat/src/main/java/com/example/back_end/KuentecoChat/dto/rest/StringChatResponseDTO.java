package com.example.back_end.KuentecoChat.dto.rest;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StringChatResponseDTO {
    private String conversationId;
    private String response;
}
