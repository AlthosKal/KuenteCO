package org.kuenteco.backend.mapper.logic.transaction;

import java.util.List;
import org.kuenteco.backend.dto.logic.transaction.TransactionDetailDTO;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.mapper.logic.budget.BudgetDetailMapper;
import org.kuenteco.backend.mapper.logic.category.CategoryDetailMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Mappings;

@Mapper(
        componentModel = "spring",
        uses = {CategoryDetailMapper.class, BudgetDetailMapper.class})
public interface TransactionDetailMapper {
    @Mappings({
        @Mapping(target = "timestamp", source = "transactionDate"),
        @Mapping(target = "type", ignore = true) // Se calcula en el servicio
    })
    TransactionDetailDTO toDto(Transaction transaction);

    List<TransactionDetailDTO> toDtoList(List<Transaction> transactions);
}
