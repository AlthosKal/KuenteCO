package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

// DTO para cuenta bancaria
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountDTO {
    @JsonProperty("account_id")
    private String accountId;

    @JsonProperty("account_number")
    private String accountNumber;

    @JsonProperty("account_type")
    private String accountType;

    @JsonProperty("account_sub_type")
    private String accountSubType;

    @JsonProperty("currency")
    private String currency;

    @JsonProperty("account_name")
    private String accountName;

    @JsonProperty("balance")
    private BalanceDTO balance;

    @JsonProperty("status")
    private String status;

    @JsonProperty("opening_date")
    private LocalDate openingDate;

    @JsonProperty("last_transaction_date")
    private LocalDateTime lastTransactionDate;

    @JsonProperty("bank_name")
    private String bankName;

    @JsonProperty("branch_code")
    private String branchCode;

    @JsonProperty("branch_name")
    private String branchName;
}
