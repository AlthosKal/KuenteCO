package com.example.back_end.connector.rest.debt;

import com.example.back_end.enums.StateDebt;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DebtDTO {
    private Integer id;
    private String name;
    private BigDecimal totalAmount;
    private BigDecimal pendingAmount;
    private LocalDateTime startDate;
    private LocalDateTime expirationDate;
    private StateDebt state;
}
