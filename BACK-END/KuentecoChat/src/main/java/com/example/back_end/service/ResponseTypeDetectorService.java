package com.example.back_end.service;

import com.example.back_end.dto.response.ai.BaseDynamicResponseDTO;

public interface ResponseTypeDetectorService {
    BaseDynamicResponseDTO detectAndCreateResponse(String prompt, String functionName, Object data);
}
