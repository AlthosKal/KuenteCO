package org.kuenteco.backend.dto.logic.transaction.bancolombia.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.PaginationDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.TransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.TransactionSummaryDTO;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionsResponseDTO {
    @JsonProperty("transactions")
    private List<TransactionDTO> transactions;

    @JsonProperty("account_id")
    private String accountId;

    @JsonProperty("pagination")
    private PaginationDTO pagination;

    @JsonProperty("summary")
    private TransactionSummaryDTO summary;
}
