package com.example.back_end.KuentecoChat.dto.rest;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DataResponseDTO {
    private String name;
    private String description;
    private List<CharDataDTO> values;
}
