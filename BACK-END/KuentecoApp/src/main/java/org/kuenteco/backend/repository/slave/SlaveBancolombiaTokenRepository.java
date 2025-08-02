package org.kuenteco.backend.repository.slave;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.kuenteco.backend.entity.BancolombiaToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveBancolombiaTokenRepository extends JpaRepository<BancolombiaToken, Long> {

    /** 1) Busca el token más reciente que sigue activo y no expirado */
    Optional<BancolombiaToken> findFirstByIsActiveTrueAndExpiresAtAfterOrderByCreatedAtDesc(
            LocalDateTime currentTime);

    /** 2) Lista todos los tokens marcados como activos */
    List<BancolombiaToken> findAllByIsActiveTrue();
}
