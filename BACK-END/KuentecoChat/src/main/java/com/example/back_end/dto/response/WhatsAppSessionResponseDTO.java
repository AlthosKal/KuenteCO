package com.example.back_end.dto.response;

import com.example.back_end.enums.SessionState;
import java.time.LocalDateTime;
import lombok.Builder;

@Builder
public record WhatsAppSessionResponseDTO(
        String phoneNumber,
        SessionState state,
        String email,
        Integer failedAttempts,
        LocalDateTime createdAt,
        LocalDateTime authenticatedAt,
        LocalDateTime blockedUntil) {
    /*
    public boolean isBlocked() {
        return state == SessionState.BLOCKED
                && blockedUntil != null
                && LocalDateTime.now().isAfter(blockedUntil);
    }

    public boolean canAuthenticate() {
        return  failedAttempts < 2 && ! isBlocked();
    }

    public void incrementFailedAttempts() {
        Integer i = this.failedAttempts++;
        if (this.failedAttempts >= 2) {
            this.state = SessionState.BLOCKED;
            this.blockedUntil = LocalDateTime.now().plusHours(1);
        }
    } */
}
