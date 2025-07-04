package org.kuenteco.backend.mapper.logic.transaction;

import java.math.BigDecimal;
import java.util.List;
import java.util.Objects;
import org.kuenteco.backend.dto.logic.transaction.ProfileWithTransactionsDTO;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.Transaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(
        componentModel = "spring",
        uses = {TransactionDetailMapper.class})
public interface ProfileWithTransactionsMapper {
    @Mapping(target = "username", source = "profile.username")
    @Mapping(target = "email", source = "profile.email")
    @Mapping(target = "startDate", source = "profile.startDate")
    @Mapping(target = "transactions", source = "transactions")
    @Mapping(
            target = "transactionCount",
            expression = "java(transactions != null ? transactions.size() : 0)")
    @Mapping(target = "totalAmount", expression = "java(calculateTotalAmount(transactions))")
    ProfileWithTransactionsDTO toDto(Profile profile, List<Transaction> transactions);

    // AGREGADO: Método auxiliar para calcular total
    default BigDecimal calculateTotalAmount(List<Transaction> transactions) {
        if (transactions == null || transactions.isEmpty()) {
            return BigDecimal.ZERO;
        }
        return transactions.stream()
                .map(Transaction::getAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
