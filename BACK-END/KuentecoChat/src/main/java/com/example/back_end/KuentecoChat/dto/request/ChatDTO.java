package com.example.back_end.KuentecoChat.dto.request;

import com.example.back_end.KuentecoChat.enums.Model;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ChatDTO {

    @NotNull(message = "The model must be defined")
    private Model model;

    private String conversationId;

    @NotBlank(message = "The prompt must be defined")
    private String prompt;

    public boolean needsConversationId() {
        return conversationId == null || conversationId.trim().isEmpty();
    }
}
