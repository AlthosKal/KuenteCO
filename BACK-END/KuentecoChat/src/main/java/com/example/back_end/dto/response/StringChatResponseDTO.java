package com.example.back_end.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StringChatResponseDTO {
    private String conversationId;
    private String response;
}
