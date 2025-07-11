package com.example.back_end.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ChatResponseDTO {
    private String conversationId;
    private DynamicAnalysisResponseDTO analysis;
}
