package com.example.back_end.connector.rest.transaction;

import com.example.back_end.enums.TransactionType;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDetailDTO {
    private Integer id;
    private Integer categoryId;
    private Integer budgetId;
    private TransactionType type;
    private BigDecimal amount;
    private LocalDateTime timestamp;
    private DescriptionTransaction description;
}
