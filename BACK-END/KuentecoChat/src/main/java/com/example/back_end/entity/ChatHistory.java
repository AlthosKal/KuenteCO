package com.example.back_end.entity;

import java.time.LocalDateTime;
import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Document(collection = "chat_history")
public class ChatHistory {
    @Id private String id;
    private String conversationId;
    private String prompt;
    private String response;
    private LocalDateTime date = LocalDateTime.now();
    private String email;

    public ChatHistory(String conversationId, String prompt, String response, String email) {
        this.conversationId = conversationId;
        this.prompt = prompt;
        this.response = response;
        this.date = LocalDateTime.now();
        this.email = email;
    }
}
