package com.example.back_end.mapper;

import com.example.back_end.connector.rest.transaction.GetTransactionDTO;
import com.example.back_end.connector.rest.transaction.TransactionSummaryDTO;
import com.example.back_end.enums.TransactionType;
import org.mapstruct.Mapper;
import org.mapstruct.Named;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
@Component
public interface TransactionMapper {

    @Named("convertToTransactionSummaryList")
    default List<TransactionSummaryDTO> convertToTransactionSummaryList(List<?> list) {
        return list.stream()
                .filter(GetTransactionDTO.class::isInstance)
                .map(GetTransactionDTO.class::cast)
                .collect(Collectors.groupingBy(
                        t -> t.getDescription() != null && t.getDescription().getDescription() != null
                                ? t.getDescription().getDescription()
                                : "General"))
                .entrySet()
                .stream()
                .map(entry -> buildSummary(entry.getKey(), entry.getValue()))
                .collect(Collectors.toList());
    }

    private TransactionSummaryDTO buildSummary(String categoryName, List<GetTransactionDTO> transactions) {
        BigDecimal totalIncome = sumByType(transactions, TransactionType.INCOME);
        BigDecimal totalExpenses = sumByType(transactions, TransactionType.EXPENSE);
        long incomeCount = countByType(transactions, TransactionType.INCOME);
        long expenseCount = countByType(transactions, TransactionType.EXPENSE);

        return TransactionSummaryDTO.builder()
                .categoryName(categoryName)
                .totalIncome(totalIncome)
                .totalExpenses(totalExpenses)
                .netAmount(totalIncome.subtract(totalExpenses))
                .transactionCount((long) transactions.size())
                .incomeCount(incomeCount)
                .expenseCount(expenseCount)
                .build();
    }

    private BigDecimal sumByType(List<GetTransactionDTO> transactions, TransactionType type) {
        return transactions.stream()
                .filter(t -> t.getDescription() != null && t.getDescription().getType() == type)
                .map(t -> BigDecimal.valueOf(t.getAmount()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private long countByType(List<GetTransactionDTO> transactions, TransactionType type) {
        return transactions.stream()
                .filter(t -> t.getDescription() != null && t.getDescription().getType() == type)
                .count();
    }

}
