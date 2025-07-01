package org.kuenteco.backend.dto.logic.debt;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

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

