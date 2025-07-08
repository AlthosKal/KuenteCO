package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "bancolombia_token")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BancolombiaToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "access_token", columnDefinition = "TEXT", nullable = false)
    private String accessToken;

    @Column(name = "token_type", length = 50)
    private String tokenType;

    @Column(name = "expires_in")
    private Long expiresIn;

    @Column(name = "scope", length = 255)
    private String scope;

    @Column(name = "refresh_token", columnDefinition = "TEXT")
    private String refreshToken;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.expiresAt == null && this.expiresIn != null) {
            this.expiresAt = this.createdAt.plusSeconds(this.expiresIn);
        }
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(this.expiresAt);
    }

    public boolean isExpiredWithBuffer(int bufferSeconds) {
        return LocalDateTime.now().plusSeconds(bufferSeconds).isAfter(this.expiresAt);
    }
}
