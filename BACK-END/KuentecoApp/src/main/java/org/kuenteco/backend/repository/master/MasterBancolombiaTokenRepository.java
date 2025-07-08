package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.BancolombiaToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterBancolombiaTokenRepository extends JpaRepository<BancolombiaToken, Long> {
    /**
     * Desactiva tokens activos (hazlo con método en el servicio)
     */
    List<BancolombiaToken> findAllByIsActiveTrue();

    /**
     * Desactiva tokens expirados (hazlo con método en el servicio)
     */
    List<BancolombiaToken> findAllByIsActiveTrueAndExpiresAtBefore(LocalDateTime currentTime);

    /**
     * Elimina tokens creados antes de cierta fecha
     */
    List<BancolombiaToken> findAllByCreatedAtBefore(LocalDateTime cutoffDate);

}
