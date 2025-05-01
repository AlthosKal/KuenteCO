package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.businesslogic.CategoryRequestDTO;
import org.kuenteco.backend.dto.businesslogic.CategoryResponseDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.enums.TransactionType;
import org.kuenteco.backend.repository.slave.SlaveTransactionRepository;
import org.mapstruct.*;
import org.springframework.beans.factory.annotation.Autowired;

import java.math.BigDecimal;
import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public abstract class CategoryMapper {

    @Autowired
    protected SlaveTransactionRepository transactionRepository;

    @Mapping(target = "accountId", source = "account.id")
    @Mapping(target = "assetId", source = "asset.id")
    @Mapping(target = "usedBudget", ignore = true)
    @Mapping(target = "remainingBudget", ignore = true)
    @Mapping(target = "usedPercentage", ignore = true)
    public abstract CategoryResponseDTO toResponseDTO(Category category);

    @AfterMapping
    protected void calculateBudgetStatistics(Category category, @MappingTarget CategoryResponseDTO responseDTO) {
        if (category.getId() != null) {
            // Calcular presupuesto usado
            List<Transaction> expenses = transactionRepository.findByCategoryIdAndType(category.getId(),
                    TransactionType.EXPENSE);
            BigDecimal usedBudget = expenses.stream().map(Transaction::getAmount).reduce(BigDecimal.ZERO,
                    BigDecimal::add);

            responseDTO.setUsedBudget(usedBudget);
            responseDTO.setRemainingBudget(category.getAssignedBudget().subtract(usedBudget));

            // Calcular porcentaje usado
            if (category.getAssignedBudget() != null && category.getAssignedBudget().compareTo(BigDecimal.ZERO) > 0) {
                responseDTO.setUsedPercentage(usedBudget.multiply(new BigDecimal("100"))
                        .divide(category.getAssignedBudget(), 2, BigDecimal.ROUND_HALF_UP));
            } else {
                responseDTO.setUsedPercentage(BigDecimal.ZERO);
            }
        }
    }

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "account", ignore = true)
    @Mapping(target = "asset", ignore = true)
    @Mapping(target = "state", constant = "ACTIVE")
    public abstract Category toEntity(CategoryRequestDTO requestDTO);

    @Mapping(target = "account", ignore = true)
    @Mapping(target = "asset", ignore = true)
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    public abstract void updateCategoryFromDTO(CategoryRequestDTO requestDTO, @MappingTarget Category category);
}
