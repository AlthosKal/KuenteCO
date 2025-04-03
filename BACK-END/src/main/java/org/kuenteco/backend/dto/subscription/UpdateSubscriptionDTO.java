package org.kuenteco.backend.dto.subscription;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.SubscriptionType;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateSubscriptionDTO {
    private SubscriptionType type;
}
