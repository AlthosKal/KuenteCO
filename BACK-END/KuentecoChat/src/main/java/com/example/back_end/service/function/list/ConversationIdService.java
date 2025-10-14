package com.example.back_end.service.function.list;

import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class ConversationIdService {
    public String generateConversationId() {
        return "conv_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
    }
}
