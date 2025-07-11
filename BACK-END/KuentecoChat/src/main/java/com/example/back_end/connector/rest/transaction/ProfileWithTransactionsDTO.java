package com.example.back_end.connector.rest.transaction;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ProfileWithTransactionsDTO {
    private String username;
    private String email;
    private Timestamp startDate;
    private List<TransactionDetailDTO> transactions;
    private Integer transactionCount;
    private BigDecimal totalAmount;
}
