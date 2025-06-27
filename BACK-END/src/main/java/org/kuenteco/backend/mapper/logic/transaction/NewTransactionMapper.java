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
        // Mapear solo los IDs, las entidades completas se resuelven en el servicio
        @Mapping(target = "category", ignore = true),
        @Mapping(target = "budget", ignore = true)
    })
    Transaction toEntity(NewTransactionDTO dto);
}
