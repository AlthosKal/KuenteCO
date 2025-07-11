package com.example.back_end.dto.response;

import com.example.back_end.dto.response.ai.BaseDynamicResponseDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DynamicAnalysisResponseDTO {
    private String conversationId;
    private BaseDynamicResponseDTO response;
}
