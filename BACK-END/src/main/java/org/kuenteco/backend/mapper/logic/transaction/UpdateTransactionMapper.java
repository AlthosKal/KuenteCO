package org.kuenteco.backend.mapper.logic.transaction;

import org.kuenteco.backend.dto.logic.transaction.UpdateTransactionDTO;
import org.kuenteco.backend.entity.Transaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Mappings;

@Mapper(componentModel = "spring")
public interface UpdateTransactionMapper {
    @Mappings({
        // Ignorar propiedades que se setean por la lógica de negocio
        @Mapping(target = "profile", ignore = true),
        @Mapping(target = "user", ignore = true),
        @Mapping(target = "transactionDate", ignore = true),
        // Mapeo de Category
        @Mapping(target = "category.user", ignore = true),
        @Mapping(target = "category.budget", ignore = true),
        @Mapping(target = "category.startDate", ignore = true),
        @Mapping(target = "category.finishDate", ignore = true),
        // Mapeo de Budget
        @Mapping(target = "budget.user", ignore = true),
        @Mapping(target = "budget.totalBudget", ignore = true),
        @Mapping(target = "budget.remainingBudget", ignore = true)
    })
    Transaction toEntity(UpdateTransactionDTO dto);
}
