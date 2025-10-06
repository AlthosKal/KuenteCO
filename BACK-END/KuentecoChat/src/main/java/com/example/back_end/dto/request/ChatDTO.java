package com.example.back_end.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ChatDTO {

    private String conversationId;

    @NotBlank(message = "The prompt must be defined")
    private String prompt;

    public boolean needsConversationId() {
        return conversationId == null || conversationId.trim().isEmpty();
    }
}
