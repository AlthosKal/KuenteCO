package org.kuenteco.backend.mapper.logic.transaction;

import org.kuenteco.backend.dto.logic.transaction.UpdateTransactionDTO;
import org.kuenteco.backend.entity.Transaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Mappings;

@Mapper(componentModel = "spring")
public interface UpdateTransactionMapper {
    @Mappings({
        // Ignorar propiedades que se agregan por la lógica de negocio
        @Mapping(target = "profile", ignore = true),
        @Mapping(target = "user", ignore = true),
        @Mapping(target = "transactionDate", ignore = true),
        // Mapear solo los IDs, las entidades completas se resuelven en el servicio
        @Mapping(target = "category", ignore = true),
        @Mapping(target = "budget", ignore = true)
    })
    Transaction toEntity(UpdateTransactionDTO dto);
}
