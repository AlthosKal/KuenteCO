package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.businesslogic.BudgetRequestDTO;
import org.kuenteco.backend.dto.businesslogic.BudgetResponseDTO;
import org.kuenteco.backend.entity.Budget;
import org.mapstruct.*;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface BudgetMapper {

    @Mapping(target = "accountId", source = "account.id")
    @Mapping(target = "accountName", source = "account.name")
    @Mapping(target = "usedPercentage", ignore = true) // Calculado después del mapeo
    BudgetResponseDTO toResponseDTO(Budget budget);

    @AfterMapping
    default void calculateUsedPercentage(Budget budget, @MappingTarget BudgetResponseDTO responseDTO) {
        if (budget.getTotalBudget() != null && budget.getTotalBudget().compareTo(java.math.BigDecimal.ZERO) > 0) {
            java.math.BigDecimal used = budget.getTotalBudget().subtract(budget.getRemainingBudget());
            responseDTO.setUsedPercentage(used.multiply(new java.math.BigDecimal("100")).divide(budget.getTotalBudget(),
                    2, java.math.BigDecimal.ROUND_HALF_UP));
        } else {
            responseDTO.setUsedPercentage(java.math.BigDecimal.ZERO);
        }
    }

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "account", ignore = true)
    @Mapping(target = "remainingBudget", source = "totalBudget") // Inicialmente igual al total
    Budget toEntity(BudgetRequestDTO requestDTO);
}
