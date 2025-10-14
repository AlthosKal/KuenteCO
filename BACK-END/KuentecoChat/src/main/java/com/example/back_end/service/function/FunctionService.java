package com.example.back_end.service.function;

import com.example.back_end.dto.request.ChatDTO;
import org.springframework.ai.chat.prompt.Prompt;

public interface FunctionService {
    String detectFunctionFromPrompt(String prompt);

    Object getFunctionData(String functionName, ChatDTO request);

    Object getFunctionData(String functionName, ChatDTO request, String authToken);

    String createContextualPrompt(String originalPrompt, String functionName, Object functionData);

    Prompt getPrompt(String userInput);

    Prompt getPrompt(ChatDTO dto, String userInput);
}
