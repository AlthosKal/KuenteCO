package com.example.back_end.KuentecoChat.dto.rest;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AnalysisResponseDTO {
    private String response;
    private String analysis;
    private DataResponseDTO data;

}
