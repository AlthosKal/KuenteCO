package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.BancolombiaToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveBancolombiaTokenRepository extends JpaRepository<BancolombiaToken, Long> {
    /**
     * Busca el token activo más reciente
     */
    Optional<BancolombiaToken> findFirstByIsActiveTrueOrderByCreatedAtDesc();
    /**

     * Busca un token válido (activo y no expirado)
     */
    Optional<BancolombiaToken> findFirstByIsActiveTrueAndExpiresAtAfterOrderByCreatedAtDesc(LocalDateTime currentTime);
    /**
     * Cuenta tokens activos
     */
    long countByIsActiveTrue();
}
