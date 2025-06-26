package org.kuenteco.backend.service.logic.budget;

import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.budget.BudgetDTO;
import org.kuenteco.backend.dto.logic.budget.NewBudgetDTO;
import org.kuenteco.backend.entity.Budget;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.exception.exceptions.BudgetException;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.budget.BudgetDetailMapper;
import org.kuenteco.backend.mapper.logic.budget.NewBudgetMapper;
import org.kuenteco.backend.mapper.logic.budget.UpdateBudgetMapper;
import org.kuenteco.backend.repository.master.MasterBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class BudgetServiceImpl implements BudgetService {
    private final MasterBudgetRepository masterBudgetRepository;
    private final SlaveBudgetRepository slaveBudgetRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final BudgetDetailMapper budgetDetailMapper;
    private final UpdateBudgetMapper updateBudgetMapper;
    private final NewBudgetMapper newBudgetMapper;

    @Override
    public Object getBudgets() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Buscando presupuestos para: {}", email);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () -> new CategoryException("Usuario no encontrado: " + email));
        return getUserBudgets(user);
    }

    @Override
    public void addBudget(NewBudgetDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Budget budget = newBudgetMapper.toEntity(dto);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new BudgetException("Usuario no encontrado: " + email));

        log.info("Registrando la presupuesto para: {}", email);
        budget.setUser(user);
        masterBudgetRepository.save(budget);
    }

    @Override
    public void updateBudget(BudgetDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Budget budget = updateBudgetMapper.toEntity(dto);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new BudgetException("Usuario no encontrado: " + email));

        log.info("Actualizando la presupuesto para: {}", email);
        budget.setUser(user);
        masterBudgetRepository.save(budget);
    }

    @Override
    public void deleteBudget(Integer id) {
        if (id == null) {
            throw new BudgetException("ID del presupuesto no puede ser nulo");
        }

        if (!slaveBudgetRepository.existsById(id)) {
            throw new BudgetException("ID del presupuesto no encontrado con el ID: " + id);
        }

        masterBudgetRepository.deleteById(id);
        log.info("Eliminando presupuesto con el ID: {}", id);
    }

    private Object getUserBudgets(User user) {
        List<Budget> budgets = slaveBudgetRepository.findByUser(user);

        if (budgets.isEmpty()) {
            return "No tienes presupuestos registrados";
        }

        return budgetDetailMapper.toDtoList(budgets);
    }
}
