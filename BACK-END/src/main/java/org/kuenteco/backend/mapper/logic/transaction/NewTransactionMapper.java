package org.kuenteco.backend.mapper.logic.transaction;

import org.kuenteco.backend.dto.logic.transaction.NewTransactionDTO;
import org.kuenteco.backend.entity.Transaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Mappings;

@Mapper(componentModel = "spring")
public interface NewTransactionMapper {
    @Mappings({
        // Ignorar propiedades que se asignan automáticamente o por lógica de negocio
        @Mapping(target = "id", ignore = true),
        @Mapping(target = "profile", ignore = true),
        @Mapping(target = "user", ignore = true),
        @Mapping(target = "transactionDate", ignore = true),
        // Mapeo de Category
        @Mapping(target = "category.profile", ignore = true),
        @Mapping(target = "category.user", ignore = true),
        @Mapping(target = "category.budget", ignore = true),
        @Mapping(target = "category.assignedBudget", ignore = true),
        @Mapping(target = "category.startDate", ignore = true),
        @Mapping(target = "category.finishDate", ignore = true),
        // Mapeo de Budget
        @Mapping(target = "budget.profile", ignore = true),
        @Mapping(target = "budget.user", ignore = true),
        @Mapping(target = "budget.totalBudget", ignore = true),
        @Mapping(target = "budget.remainingBudget", ignore = true)
    })
    Transaction toEntity(NewTransactionDTO dto);
}
