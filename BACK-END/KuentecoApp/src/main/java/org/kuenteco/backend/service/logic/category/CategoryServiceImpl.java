package org.kuenteco.backend.service.logic.category;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.dto.logic.category.CategoryReportDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.dto.logic.category.TransactionsByCategoryDTO;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.TransactionDetailDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.TransactionType;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.category.CategoryDetailMapper;
import org.kuenteco.backend.mapper.logic.category.CategoryReportMapper;
import org.kuenteco.backend.mapper.logic.category.NewCategoryMapper;
import org.kuenteco.backend.mapper.logic.category.UpdateCategoryMapper;
import org.kuenteco.backend.mapper.logic.transaction.TransactionDetailMapper;
import org.kuenteco.backend.repository.master.MasterCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveTransactionRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {
    private final MasterCategoryRepository masterCategoryRepository;
    private final SlaveCategoryRepository slaveCategoryRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final CategoryDetailMapper categoryDetailMapper;
    private final UpdateCategoryMapper updateCategoryMapper;
    private final NewCategoryMapper newCategoryMapper;
    private final SlaveBudgetRepository slaveBudgetRepository;
    private final SlaveTransactionRepository slaveTransactionRepository;
    private final CategoryReportMapper categoryReportMapper;
    private final TransactionDetailMapper transactionDetailMapper;

    @Override
    public Object getCategories() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new CategoryException("Endpoint solo disponible para usuarios");
        }

        log.info("Obteniendo Rubros para: {}", email);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () -> new CategoryException("Usuario no encontrado: " + email));
        return getUserCategories(user);
    }

    @Override
    public CategoryReportDTO getCategoryReport(Integer categoryId) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new CategoryException("Endpoint solo disponible para usuarios");
        }

        log.info("Generando reporte para la categoría {} del usuario: {}", categoryId, email);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () -> new CategoryException("Usuario no encontrado: " + email));

        Category category =
                slaveCategoryRepository
                        .findByIdAndUser(categoryId, user)
                        .orElseThrow(
                                () ->
                                        new CategoryException(
                                                "Categoría no encontrada con el Id: "
                                                        + categoryId));

        List<Transaction> transactions =
                slaveTransactionRepository.findByCategoryOrderByTransactionDateDesc(category);

        CategoryReportDTO dto = categoryReportMapper.toDTO(category);

        calculateCategoryStatistics(dto, transactions);

        List<TransactionDetailDTO> dtos = transactionDetailMapper.toDtoList(transactions);
        dto.setTransactions(dtos);

        log.info("Reporte generado exitosamente para la categoría: {}", categoryId);
        return dto;
    }

    @Override
    public Object getTransactionsByCategory() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new CategoryException("Endpoint solo disponible para usuarios");
        }
        List<TransactionsByCategoryDTO> dto =
                slaveCategoryRepository.getTransactionsByCategoryAndUserEmail(email);
        if (dto.isEmpty()) {
            return "No tienes categorías registradas";
        }
        return dto;
    }

    @Override
    public void addCategory(NewCategoryDTO dto) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new CategoryException("Endpoint solo disponible para usuarios");
        }
        Category category = prepareNewCategory(dto);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () -> new CategoryException("Usuario no encontrado: " + email));

        log.info("Registrando la categoria para: {}", email);
        category.setUser(user);
        if (dto.getStartDate() == null) {
            category.setStartDate(LocalDateTime.now());
        }
        masterCategoryRepository.save(category);
    }

    @Override
    public void updateCategory(CategoryDTO dto) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new CategoryException("Endpoint solo disponible para usuarios");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () -> new CategoryException("Usuario no encontrado: " + email));

        Category category = slaveCategoryRepository.getCategoryByUserAndId(user,dto.getId()).orElseThrow(()-> new CategoryException("Categoría no encontrada: ") );
        updateCategoryMapper.toEntity(dto);
        resolveBudget(dto.getBudgetId(), category);
        log.info("Actualizando la categoria para: {}", email);
        category.setUser(user);
        masterCategoryRepository.save(category);
    }

    @Override
    public void deleteCategory(Integer id) {
        AuthCredentials credentials = getCredentials();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new CategoryException("Endpoint solo disponible para usuarios");
        }
        if (id == null) {
            throw new CategoryException("Id del rubro no puede ser nulo");
        }

        if (!slaveCategoryRepository.existsById(id)) {
            throw new CategoryException("Rubro no encontrado con el ID: " + id);
        }

        masterCategoryRepository.deleteById(id);
        log.info("Categoría eliminada con el ID: {}", id);
    }

    private Object getUserCategories(User user) {
        List<Category> categories = slaveCategoryRepository.findByUser(user);

        if (categories.isEmpty()) {
            return "No tienes rubros registrados";
        }

        return categoryDetailMapper.toDtoList(categories);
    }

    private void calculateCategoryStatistics(
            CategoryReportDTO dto, List<Transaction> transactions) {
        BigDecimal totalSpent =
                transactions.stream()
                        .filter(
                                transaction ->
                                        TransactionType.EXPENSE.equals(
                                                transaction.getDescription().getType()))
                        .map(Transaction::getAmount)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalIncome =
                transactions.stream()
                        .filter(
                                transaction ->
                                        TransactionType.INCOME.equals(
                                                transaction.getDescription().getType()))
                        .map(Transaction::getAmount)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

        dto.setTotalSpent(totalSpent);
        dto.setTotalIncome(totalIncome);
        dto.setTransactionCount(transactions.size());
        Optional.ofNullable(dto.getCategory().getDescription().getAssignedBudget())
                .map(budget -> budget.subtract(totalSpent))
                .ifPresentOrElse(
                        dto::setCategoryRemainingBudget,
                        () -> dto.setCategoryRemainingBudget(null));
    }

    private Category prepareNewCategory(NewCategoryDTO dto) {
        Category category = newCategoryMapper.toEntity(dto);
        resolveBudget(dto.getBudgetId(), category);
        return category;
    }
    private void resolveBudget(Integer budgetId, Category category) {
        if (budgetId != null) {
            category.setBudget(
                    slaveBudgetRepository
                            .findById(budgetId)
                            .orElseThrow(
                                    () ->
                                            new CategoryException(
                                                    "Budget no encontrado por el Id: "
                                                            + budgetId)));
        } else {
            category.setBudget(null);
        }
    }
}
