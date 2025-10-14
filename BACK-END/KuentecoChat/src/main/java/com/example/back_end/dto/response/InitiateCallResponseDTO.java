package com.example.back_end.dto.response;

import lombok.Builder;

@Builder
public record InitiateCallResponseDTO(String callSId, String message) {}
