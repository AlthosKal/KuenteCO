package org.kuenteco.backend.service.businesslogic.category;

import org.kuenteco.backend.dto.businesslogic.CategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.enums.State;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

public interface CategoryService {
    /**
     * Crea una nueva categoría
     *
     * @param idAccount
     *            ID de la cuenta
     * @param idAsset
     *            ID del activo (opcional)
     * @param name
     *            Nombre de la categoría
     * @param description
     *            Descripción de la categoría
     * @param assignedBudget
     *            Presupuesto asignado
     * @param startDate
     *            Fecha de inicio
     * @param finishDate
     *            Fecha de finalización
     *
     * @return La categoría creada
     */
    Category createCategory(Integer idAccount, Integer idAsset, String name, String description,
            BigDecimal assignedBudget, Timestamp startDate, Timestamp finishDate);

    /**
     * Actualiza una categoría existente
     *
     * @param idCategory
     *            ID de la categoría
     * @param name
     *            Nombre actualizado
     * @param description
     *            Descripción actualizada
     * @param assignedBudget
     *            Presupuesto asignado actualizado
     * @param startDate
     *            Fecha de inicio actualizada
     * @param finishDate
     *            Fecha de finalización actualizada
     * @param state
     *            Estado actualizado
     *
     * @return La categoría actualizada
     */
    Category updateCategory(Integer idCategory, String name, String description, BigDecimal assignedBudget,
            Timestamp startDate, Timestamp finishDate, State state);

    /**
     * Obtiene una categoría por su ID
     *
     * @param idCategory
     *            ID de la categoría
     *
     * @return Optional con la categoría si existe
     */
    Optional<Category> getCategoryById(Integer idCategory);

    /**
     * Obtiene todas las categorías de una cuenta
     *
     * @param idAccount
     *            ID de la cuenta
     *
     * @return Lista de categorías
     */
    List<Category> getCategoriesByAccountId(Integer idAccount);

    /**
     * Asigna presupuesto a una categoría
     *
     * @param idCategory
     *            ID de la categoría
     * @param amount
     *            Monto a asignar
     *
     * @return La categoría actualizada
     */
    Category assignBudgetToCategory(Integer idCategory, BigDecimal amount);

    /**
     * Cambia el estado de una categoría
     *
     * @param idCategory
     *            ID de la categoría
     * @param state
     *            Nuevo estado
     *
     * @return La categoría actualizada
     */
    Category changeState(Integer idCategory, State state);

    /**
     * Obtiene las estadísticas de una categoría
     *
     * @param idCategory
     *            ID de la categoría
     *
     * @return DTO con estadísticas de la categoría
     */
    CategoryDTO getCategoryStatistics(Integer idCategory);
}
