package org.kuenteco.backend.dto.logic.transaction.kuenteco;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDetailDTO {
    private Integer id;
    private Integer categoryId;
    private Integer budgetId;
    private String name;
    private BigDecimal amount;
    private LocalDateTime timestamp;
    private DescriptionTransaction description;
}
