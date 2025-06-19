package org.kuenteco.backend.dto.subscription;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SubscriptionDetailDTO {
    private String username;
    private SubscriptionType type;
    private LocalDateTime startDate;
    private LocalDateTime expirationDate;
    private BigDecimal amount;
}
