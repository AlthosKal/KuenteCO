package org.kuenteco.backend.service.businesslogic.category;

import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.repository.master.MasterAccountRepository;
import org.kuenteco.backend.repository.master.MasterAssetRepository;
import org.kuenteco.backend.repository.master.MasterCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveAccountRepository;
import org.kuenteco.backend.repository.slave.SlaveAssetRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.businesslogic.CategoryDTO;
import org.kuenteco.backend.entity.Account;
import org.kuenteco.backend.entity.Asset;
import org.kuenteco.backend.entity.Budget;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.TransactionType;
import org.kuenteco.backend.repository.master.MasterAccountRepository;
import org.kuenteco.backend.repository.master.MasterAssetRepository;
import org.kuenteco.backend.repository.master.MasterBudgetRepository;
import org.kuenteco.backend.repository.master.MasterCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveAccountRepository;
import org.kuenteco.backend.repository.slave.SlaveAssetRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveTransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final MasterCategoryRepository masterCategoryRepository;
    private final SlaveCategoryRepository slaveCategoryRepository;

    private final MasterAccountRepository masterAccountRepository;
    private final SlaveAccountRepository slaveAccountRepository;

    private final MasterAssetRepository masterAssetRepository;
    private final SlaveAssetRepository slaveAssetRepository;

    private final MasterBudgetRepository masterBudgetRepository;
    private final SlaveBudgetRepository slaveBudgetRepository;

    private final SlaveTransactionRepository slaveTransactionRepository;

    @Override
    @Transactional
    public Category createCategory(Integer idAccount, Integer idAsset, String name,
                                   DescriptionCategory description, BigDecimal assignedBudget,
                                   Timestamp startDate, Timestamp finishDate) {
        Account account = masterAccountRepository.findById(idAccount)
                .orElseThrow(() -> new RuntimeException("Cuenta no encontrada con ID: " + idAccount));

        Asset asset = null;
        if (idAsset != null) {
            asset = masterAssetRepository.findById(idAsset)
                    .orElseThrow(() -> new RuntimeException("Activo no encontrado con ID: " + idAsset));
        }

        // Validar que hay suficiente presupuesto disponible
        if (assignedBudget != null && assignedBudget.compareTo(BigDecimal.ZERO) > 0) {
            Budget budget = slaveBudgetRepository.findByAccountId(idAccount)
                    .orElseThrow(() -> new RuntimeException("No existe un presupuesto para esta cuenta"));

            if (budget.getRemainingBudget().compareTo(assignedBudget) < 0) {
                throw new RuntimeException("Presupuesto insuficiente para asignar a la categoría");
            }

            // Actualizar el presupuesto restante
            budget.setRemainingBudget(budget.getRemainingBudget().subtract(assignedBudget));
            masterBudgetRepository.save(budget);
        }

        Category category = new Category();
        category.setAccount(account);
        category.setAsset(asset);
        category.setName(name);
        category.setDescription(description);
        category.setAssignedBudget(assignedBudget != null ? assignedBudget : BigDecimal.ZERO);
        category.setStartDate(startDate);
        category.setFinishDate(finishDate);
        category.setState(State.ACTIVE);

        return masterCategoryRepository.save(category);
    }

    @Override
    @Transactional
    public Category updateCategory(Integer idCategory, String name, DescriptionCategory description,
                                   BigDecimal assignedBudget, Timestamp startDate,
                                   Timestamp finishDate, State state) {
        Category category = masterCategoryRepository.findById(idCategory)
                .orElseThrow(() -> new RuntimeException("Categoría no encontrada con ID: " + idCategory));

        Budget budget = slaveBudgetRepository.findByAccountId(category.getAccount().getId())
                .orElseThrow(() -> new RuntimeException("No existe un presupuesto para esta cuenta"));

        // Si hay cambio en el presupuesto asignado, ajustar el presupuesto general
        if (assignedBudget != null && !assignedBudget.equals(category.getAssignedBudget())) {
            BigDecimal difference = assignedBudget.subtract(category.getAssignedBudget());

            // Verificar que hay suficiente presupuesto disponible si se está aumentando
            if (difference.compareTo(BigDecimal.ZERO) > 0 &&
                    budget.getRemainingBudget().compareTo(difference) < 0) {
                throw new RuntimeException("Presupuesto insuficiente para el ajuste solicitado");
            }

            // Actualizar el presupuesto restante
            budget.setRemainingBudget(budget.getRemainingBudget().subtract(difference));
            masterBudgetRepository.save(budget);
        }

        if (name != null) category.setName(name);
        if (description != null) category.setDescription(description);
        if (assignedBudget != null) category.setAssignedBudget(assignedBudget);
        if (startDate != null) category.setStartDate(startDate);
        if (finishDate != null) category.setFinishDate(finishDate);
        if (state != null) category.setState(state);

        return masterCategoryRepository.save(category);
    }

    @Override
    public Optional<Category> getCategoryById(Integer idCategory) {
        return slaveCategoryRepository.findById(idCategory);
    }

    @Override
    public List<Category> getCategoriesByAccountId(Integer idAccount) {
        return slaveCategoryRepository.findByAccountId(idAccount);
    }

    @Override
    @Transactional
    public Category assignBudgetToCategory(Integer idCategory, BigDecimal amount) {
        Category category = masterCategoryRepository.findById(idCategory)
                .orElseThrow(() -> new RuntimeException("Categoría no encontrada con ID: " + idCategory));

        Budget budget = slaveBudgetRepository.findByAccountId(category.getAccount().getId())
                .orElseThrow(() -> new RuntimeException("No existe un presupuesto para esta cuenta"));

        // Verificar que hay suficiente presupuesto disponible
        if (budget.getRemainingBudget().compareTo(amount) < 0) {
            throw new RuntimeException("Presupuesto insuficiente para asignar a la categoría");
        }

        // Actualizar el presupuesto de la categoría
        category.setAssignedBudget(category.getAssignedBudget().add(amount));

        // Actualizar el presupuesto restante
        budget.setRemainingBudget(budget.getRemainingBudget().subtract(amount));
        masterBudgetRepository.save(budget);

        return masterCategoryRepository.save(category);
    }

    @Override
    @Transactional
    public Category changeState(Integer idCategory, State state) {
        Category category = masterCategoryRepository.findById(idCategory)
                .orElseThrow(() -> new RuntimeException("Categoría no encontrada con ID: " + idCategory));

        category.setState(state);

        // Si la categoría se desactiva, devolver el presupuesto no utilizado
        if (state == State.INACTIVE) {
            Budget budget = slaveBudgetRepository.findByAccountId(category.getAccount().getId())
                    .orElseThrow(() -> new RuntimeException("No existe un presupuesto para esta cuenta"));

            // Calcular presupuesto utilizado
            BigDecimal usedBudget = slaveTransactionRepository.findByCategoryId(idCategory)
                    .stream()
                    .filter(t -> t.getType() == TransactionType.EXPENSE)
                    .map(Transaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Calcular presupuesto no utilizado
            BigDecimal unusedBudget = category.getAssignedBudget().subtract(usedBudget);
            if (unusedBudget.compareTo(BigDecimal.ZERO) > 0) {
                // Devolver al presupuesto general
                budget.setRemainingBudget(budget.getRemainingBudget().add(unusedBudget));
                masterBudgetRepository.save(budget);
            }
        }

        return masterCategoryRepository.save(category);
    }

    @Override
    public CategoryDTO getCategoryStatistics(Integer idCategory) {
        Category category = slaveCategoryRepository.findById(idCategory)
                .orElseThrow(() -> new RuntimeException("Categoría no encontrada con ID: " + idCategory));

        // Calcular ingresos de la categoría
        BigDecimal totalIncome = slaveTransactionRepository.findByCategoryId(idCategory)
                .stream()
                .filter(t -> t.getType() == TransactionType.INCOME)
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Calcular gastos de la categoría
        BigDecimal totalExpenses = slaveTransactionRepository.findByCategoryId(idCategory)
                .stream()
                .filter(t -> t.getType() == TransactionType.EXPENSE)
                .map(Transaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Calcular balance
        BigDecimal balance = totalIncome.subtract(totalExpenses);

        // Calcular presupuesto restante
        BigDecimal remainingBudget = category.getAssignedBudget().subtract(totalExpenses);

        return new CategoryDTO(
                totalIncome,
                totalExpenses,
                balance,
                category.getAssignedBudget(),
                remainingBudget.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : remainingBudget
        );
    }
}