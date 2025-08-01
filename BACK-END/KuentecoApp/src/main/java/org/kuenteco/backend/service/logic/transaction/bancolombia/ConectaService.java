package org.kuenteco.backend.service.logic.transaction.bancolombia;

import org.kuenteco.backend.dto.logic.transaction.bancolombia.BancolombiaTransactionRequestDTO;

public interface ConectaService {
    /**
     * Obtiene las transacciones desde Bancolombia para un tercero específico
     *
     * @param dto Datos de la solicitud de transacciones
     * @return URL del archivo con las transacciones
     */
    String getTransactionsFromRequest(BancolombiaTransactionRequestDTO dto);

    /**
     * Verifica el estado de salud del servicio de información transaccional de Bancolombia
     *
     * @return true si el servicio está disponible, false en caso contrario
     */
    boolean checkHealthStatus();
}
