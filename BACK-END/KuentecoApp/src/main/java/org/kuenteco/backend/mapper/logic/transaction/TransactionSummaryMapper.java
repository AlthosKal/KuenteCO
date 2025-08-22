package org.kuenteco.backend.mapper.logic.transaction;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import org.kuenteco.backend.dto.logic.transaction.kuenteco.TransactionSummaryDTO;
import org.springframework.stereotype.Component;

@Component
public class TransactionSummaryMapper {

    public TransactionSummaryDTO fromObjectArray(Object[] row) {
        return TransactionSummaryDTO.builder()
                .ownerUserId((String) row[0])
                .transactionOwnerType((String) row[1])
                .profileId((Integer) row[2])
                .transactionId((Integer) row[3])
                .transactionName((String) row[4])
                .categoryName((String) row[5])
                .budgetName((String) row[6])
                .debtName((String) row[7])
                .transactionCount((Long) row[8])
                .incomeCount((Long) row[9])
                .expenseCount((Long) row[10])
                .totalIncome((BigDecimal) row[11])
                .totalExpenses((BigDecimal) row[12])
                .netAmount((BigDecimal) row[13])
                .firstTransactionDate(convertToLocalDateTime(row[14]))
                .lastTransactionDate(convertToLocalDateTime(row[15]))
                .build();
    }

    public List<TransactionSummaryDTO> fromObjectArrayList(List<Object[]> rows) {
        return rows.stream().map(this::fromObjectArray).collect(Collectors.toList());
    }

    private LocalDateTime convertToLocalDateTime(Object value) {
        if (value == null) return null;
        if (value instanceof LocalDateTime) return (LocalDateTime) value;
        if (value instanceof Timestamp) return ((Timestamp) value).toLocalDateTime();
        if (value instanceof java.sql.Date)
            return ((java.sql.Date) value).toLocalDate().atStartOfDay();
        return null;
    }
}
