package org.kuenteco.backend.mapper.logic.transaction;

import org.kuenteco.backend.dto.logic.transaction.kuenteco.TransactionSummaryDTO;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class TransactionSummaryMapper {

    public TransactionSummaryDTO fromObjectArray(Object[] row) {
        return TransactionSummaryDTO.builder()
                .ownerUserId((String) row[0])
                .transactionOwnerType((String) row[1])
                .profileId((Integer) row[2])
                .transactionName((String) row[3])
                .categoryName((String) row[4])
                .budgetName((String) row[5])
                .debtName((String) row[6])
                .transactionCount((Long) row[7])
                .incomeCount((Long) row[8])
                .expenseCount((Long) row[9])
                .totalIncome((BigDecimal) row[10])
                .totalExpenses((BigDecimal) row[11])
                .netAmount((BigDecimal) row[12])
                .firstTransactionDate(convertToLocalDateTime(row[13]))
                .lastTransactionDate(convertToLocalDateTime(row[14]))
                .build();
    }

    public List<TransactionSummaryDTO> fromObjectArrayList(List<Object[]> rows) {
        return rows.stream()
                .map(this::fromObjectArray)
                .collect(Collectors.toList());
    }

    private LocalDateTime convertToLocalDateTime(Object value) {
        if (value == null) return null;
        if (value instanceof LocalDateTime) return (LocalDateTime) value;
        if (value instanceof Timestamp) return ((Timestamp) value).toLocalDateTime();
        if (value instanceof java.sql.Date) return ((java.sql.Date) value).toLocalDate().atStartOfDay();
        return null;
    }
}
