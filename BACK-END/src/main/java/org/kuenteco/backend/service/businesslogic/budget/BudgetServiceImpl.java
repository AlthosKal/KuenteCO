package org.kuenteco.backend.service.businesslogic.budget;

import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.businesslogic.BalanceDTO;
import org.kuenteco.backend.entity.Account;
import org.kuenteco.backend.entity.Budget;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.enums.TransactionType;
import org.kuenteco.backend.repository.master.MasterAccountRepository;
import org.kuenteco.backend.repository.master.MasterBudgetRepository;
import org.kuenteco.backend.repository.master.MasterCategoryRepository;
import org.kuenteco.backend.repository.master.MasterTransactionRepository;
import org.kuenteco.backend.repository.slave.SlaveAccountRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveTransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BudgetServiceImpl implements BudgetService {

    private final MasterBudgetRepository masterBudgetRepository;
    private final SlaveBudgetRepository slaveBudgetRepository;

    private final MasterAccountRepository masterAccountRepository;
    private final SlaveAccountRepository slaveAccountRepository;

    private final MasterCategoryRepository masterCategoryRepository;
    private final MasterTransactionRepository masterTransactionRepository;
    private final SlaveTransactionRepository slaveTransactionRepository;

    @Override
    @Transactional
    public Budget createBudget(Integer idAccount, BigDecimal totalBudget) {
        Account account = masterAccountRepository.findById(idAccount)
                .orElseThrow(() -> new RuntimeException("Cuenta no encontrada con ID: " + idAccount));

        // Verificar si ya existe un presupuesto para esta cuenta
        Optional<Budget> existingBudget = slaveBudgetRepository.findByAccountId(idAccount);
        if (existingBudget.isPresent()) {
            throw new RuntimeException("Ya existe un presupuesto para esta cuenta");
        }

        Budget budget = new Budget();
        budget.setAccount(account);
        budget.setTotalBudget(totalBudget);
        budget.setRemainingBudget(totalBudget); // Inicialmente, el presupuesto restante es igual al total

        return masterBudgetRepository.save(budget);
    }

    @Override
    @Transactional
    public Budget updateTotalBudget(Integer idAccount, BigDecimal newTotalBudget) {
        Budget budget = slaveBudgetRepository.findByAccountId(idAccount).orElseThrow(
                () -> new RuntimeException("Presupuesto no encontrado para la cuenta con ID: " + idAccount));

        BigDecimal difference = newTotalBudget.subtract(budget.getTotalBudget());

        budget.setTotalBudget(newTotalBudget);
        // Ajustar el presupuesto restante proporcionalmente
        budget.setRemainingBudget(budget.getRemainingBudget().add(difference));

        return masterBudgetRepository.save(budget);
    }

    @Override
    @Transactional
    public Budget updateRemainingBudget(Integer idAccount, BigDecimal remainingBudget) {
        Budget budget = slaveBudgetRepository.findByAccountId(idAccount).orElseThrow(
                () -> new RuntimeException("Presupuesto no encontrado para la cuenta con ID: " + idAccount));

        budget.setRemainingBudget(remainingBudget);
        return masterBudgetRepository.save(budget);
    }

    @Override
    public Optional<Budget> getBudgetByAccountId(Integer idAccount) {
        return slaveBudgetRepository.findByAccountId(idAccount);
    }

    @Override
    @Transactional
    public Budget recalculateRemainingBudget(Integer idAccount) {
        Budget budget = slaveBudgetRepository.findByAccountId(idAccount).orElseThrow(
                () -> new RuntimeException("Presupuesto no encontrado para la cuenta con ID: " + idAccount));

        // Sumar todos los presupuestos asignados a categorías
        List<Category> categories = masterCategoryRepository.findByAccountId(idAccount);
        BigDecimal totalAssigned = categories.stream().map(Category::getAssignedBudget).filter(bd -> bd != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Calcular presupuesto restante
        BigDecimal remainingBudget = budget.getTotalBudget().subtract(totalAssigned);
        budget.setRemainingBudget(remainingBudget);

        return masterBudgetRepository.save(budget);
    }

    @Override
    public BalanceDTO getFinancialBalance(Integer idAccount) {
        // Obtener el presupuesto
        Budget budget = slaveBudgetRepository.findByAccountId(idAccount).orElse(new Budget());

        // Calcular activos totales
        BigDecimal totalAssets = slaveTransactionRepository.findByAccountIdAndType(idAccount, TransactionType.INCOME)
                .stream().map(Transaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

        // Calcular deudas totales
        BigDecimal totalDebts = slaveTransactionRepository.findByAccountIdAndType(idAccount, TransactionType.EXPENSE)
                .stream().map(Transaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

        // Calcular patrimonio (activos - deudas)
        BigDecimal equity = totalAssets.subtract(totalDebts);

        return new BalanceDTO(totalAssets, totalDebts, equity,
                budget.getTotalBudget() != null ? budget.getTotalBudget() : BigDecimal.ZERO,
                budget.getRemainingBudget() != null ? budget.getRemainingBudget() : BigDecimal.ZERO);
    }
}