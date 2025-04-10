package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.businesslogic.TransactionRequestDTO;
import org.kuenteco.backend.dto.businesslogic.TransactionResponseDTO;
import org.kuenteco.backend.entity.Transaction;
import org.mapstruct.*;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface TransactionMapper {

    @Mapping(target = "accountId", source = "account.id")
    @Mapping(target = "categoryId", source = "category.id")
    @Mapping(target = "categoryName", source = "category.name")
    @Mapping(target = "relatedDebtId", source = "relatedDebt.id")
    @Mapping(target = "relatedGoalId", source = "relatedGoal.id")
    TransactionResponseDTO toResponseDTO(Transaction transaction);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "account", ignore = true)
    @Mapping(target = "category", ignore = true)
    @Mapping(target = "relatedDebt", ignore = true)
    @Mapping(target = "relatedGoal", ignore = true)
    @Mapping(target = "exchangeRate", ignore = true)
    Transaction toEntity(TransactionRequestDTO requestDTO);
}
