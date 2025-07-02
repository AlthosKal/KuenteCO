package org.kuenteco.backend.dto.subscription.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.subscription.response.extra.TransactionData;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class WompiTransactionResponseDTO {
    public TransactionData data;
}
