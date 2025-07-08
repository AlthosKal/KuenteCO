package org.kuenteco.backend.mapper.logic.transaction.kuenteco;

import org.kuenteco.backend.dto.logic.transaction.kuenteco.NewTransactionDTO;
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
        // Mapear solo los IDs, las entidades completas se resuelven en el servicio
        @Mapping(target = "category.id", source = "categoryId"),
        @Mapping(target = "budget.id", source = "budgetId"),
        @Mapping(target = "debt.id", source = "debtId")
    })
    Transaction toEntity(NewTransactionDTO dto);
}
