package org.kuenteco.backend.mapper.logic.transaction;

import java.util.List;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.TransactionDetailDTO;
import org.kuenteco.backend.entity.Transaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Mappings;

@Mapper(componentModel = "spring")
public interface TransactionDetailMapper {
        @Mapping(target = "timestamp", source = "transactionDate")
        @Mapping(target = "categoryId", source = "category.id")
        @Mapping(target = "budgetId", source = "budget.id")
        @Mapping(target = "type", ignore = true) // Se calcula en el servicio

    TransactionDetailDTO toDto(Transaction transaction);

    List<TransactionDetailDTO> toDtoList(List<Transaction> transactions);
}
