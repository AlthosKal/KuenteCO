package com.example.back_end.repository;

import com.example.back_end.entity.ChatHistory;
import java.util.List;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AiHistoryRepository extends MongoRepository<ChatHistory, String> {
    List<ChatHistory> findByConversationId(String conversationId);

    List<ChatHistory> findByEmail(String email);
}
