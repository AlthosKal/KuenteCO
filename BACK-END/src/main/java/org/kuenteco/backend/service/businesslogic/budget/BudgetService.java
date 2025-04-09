package org.kuenteco.backend.service.businesslogic.budget;

import org.kuenteco.backend.dto.businesslogic.BalanceDTO;
import org.kuenteco.backend.entity.Budget;

import java.math.BigDecimal;
import java.util.Optional;

public interface BudgetService {
    /**
     * Crea un nuevo presupuesto para una cuenta
     * @param idAccount ID de la cuenta
     * @param totalBudget Monto total del presupuesto
     * @return El presupuesto creado
     */
    Budget createBudget(Integer idAccount, BigDecimal totalBudget);

    /**
     * Actualiza el presupuesto total de una cuenta
     * @param idAccount ID de la cuenta
     * @param newTotalBudget Nuevo monto total del presupuesto
     * @return El presupuesto actualizado
     */
    Budget updateTotalBudget(Integer idAccount, BigDecimal newTotalBudget);

    /**
     * Actualiza el presupuesto restante de una cuenta
     * @param idAccount ID de la cuenta
     * @param remainingBudget Nuevo monto restante del presupuesto
     * @return El presupuesto actualizado
     */
    Budget updateRemainingBudget(Integer idAccount, BigDecimal remainingBudget);

    /**
     * Obtiene el presupuesto de una cuenta
     * @param idAccount ID de la cuenta
     * @return Optional con el presupuesto si existe
     */
    Optional<Budget> getBudgetByAccountId(Integer idAccount);

    /**
     * Recalcula el presupuesto restante basado en las transacciones y categorías
     * @param idAccount ID de la cuenta
     * @return El presupuesto actualizado
     */
    Budget recalculateRemainingBudget(Integer idAccount);

    /**
     * Obtiene el balance financiero completo de la cuenta
     * @param idAccount ID de la cuenta
     * @return DTO con el balance financiero
     */
    BalanceDTO getFinancialBalance(Integer idAccount);
}
