package org.kuenteco.backend.service.logic.transaction.bancolombia;

import org.kuenteco.backend.entity.BancolombiaToken;

public interface BancolombiaAuthService {

    /** Obtiene un token válido desde la base de datos o solicita uno nuevo si no hay válido. */
    String getValidToken();

    /** Fuerza la solicitud de un nuevo token, desactivando los anteriores. */
    String requestNewToken();

    /** Invalida todos los tokens activos (se usan para forzar renovación manual). */
    void invalidateToken();

    /** Limpia tokens expirados y elimina los muy antiguos (más de 7 días). */
    void cleanupExpiredTokens();

    /** Verifica si hay un token válido activo en la base de datos. */
    boolean hasValidToken();

    /** Devuelve el token actual válido (si lo hay). */
    BancolombiaToken getCurrentToken();
}
