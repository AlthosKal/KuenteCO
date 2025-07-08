package com.example.back_end.KuentecoChat.dto.request;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatHistoryDTO {
    private String conversationId;
    private String prompt;
    private String response;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime date;

    public ChatHistoryDTO(String conversationId, String prompt, String response) {
        this(conversationId, prompt, response, LocalDateTime.now());
    }
}
