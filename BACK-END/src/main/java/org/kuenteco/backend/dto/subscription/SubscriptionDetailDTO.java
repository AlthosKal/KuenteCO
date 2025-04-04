package org.kuenteco.backend.dto.subscription;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.SubscriptionType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SubscriptionDetailDTO {
    private String accountName;
    private SubscriptionType type;
    private LocalDateTime startDate;
    private LocalDateTime expirationDate;
    private BigDecimal amount;
}
