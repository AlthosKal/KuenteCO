package com.example.back_end.KuentecoChat.dto.rest;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ChatResponseDTO {
    private String conversationId;
    private AnalysisResponseDTO analysis;
}
