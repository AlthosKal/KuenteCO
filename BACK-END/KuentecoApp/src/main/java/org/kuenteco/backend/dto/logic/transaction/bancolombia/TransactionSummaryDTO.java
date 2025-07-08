package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionSummaryDTO {
    @JsonProperty("total_income")
    private BigDecimal totalIncome;

    @JsonProperty("total_expense")
    private BigDecimal totalExpense;

    @JsonProperty("net_amount")
    private BigDecimal netAmount;

    @JsonProperty("transaction_count")
    private Integer transactionCount;

    @JsonProperty("date_range")
    private DateRangeDTO dateRange;
}
