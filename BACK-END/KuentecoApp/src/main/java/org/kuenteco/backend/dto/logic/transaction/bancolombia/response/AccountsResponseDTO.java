package org.kuenteco.backend.dto.logic.transaction.bancolombia.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.AccountDTO;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.PaginationDTO;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountsResponseDTO {
    @JsonProperty("accounts")
    private List<AccountDTO> accounts;

    @JsonProperty("pagination")
    private PaginationDTO pagination;
}
