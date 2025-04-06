package org.kuenteco.backend.service.auth;

public interface TokenBlacklistService {
    void addToBlacklist(String token);

    boolean isBlacklisted(String token);
}
