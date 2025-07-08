package com.example.back_end.KuentecoChat.entity;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Document(collection = "chat_history")
public class ChatHistory {
    @Id
    private String id;
    private String conversationId;
    private String prompt;
    private String response;
    private LocalDateTime date = LocalDateTime.now();
    private String username;

    public ChatHistory(String conversationId, String prompt, String response) {
        this.conversationId = conversationId;
        this.prompt = prompt;
        this.response = response;
        this.date = LocalDateTime.now();
    }
}
