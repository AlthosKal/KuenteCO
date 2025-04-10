package org.kuenteco.backend.dto.businesslogic;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.enums.TransactionType;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TransactionResponseDTO {
    private Integer id;
    private Integer accountId;
    private Integer categoryId;
    private String categoryName;
    private TransactionType type;
    private BigDecimal amount;
    private Timestamp transactionDate;
    private DescriptionTransaction description;
    private Integer relatedDebtId;
    private Integer relatedGoalId;
}