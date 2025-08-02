package com.example.back_end.connector.rest.debt;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DebtSummaryDTO {
    private String userId;
    private String ownerUserId;
    private String username;
    private Long totalDebts;
    private Long activeDebts;
    private Long paidDebts;
    private Long overdueDebts;
    private Long refinancedDebts;
    private Long inMoratiumDebts;
    private Long cancelledDebts;
    private BigDecimal totalDebtAmount;
    private BigDecimal totalPendingAmount;
    private BigDecimal activePendingAmount;
    private LocalDateTime nextDueDate;
    private Long expiredActiveDebts;
}
