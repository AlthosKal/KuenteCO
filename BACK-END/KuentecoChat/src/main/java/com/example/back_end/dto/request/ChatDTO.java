package com.example.back_end.dto.request;

import com.example.back_end.enums.Model;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
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
