package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDTO {
    @JsonProperty("transaction_id")
    private String transactionId;

    @JsonProperty("account_id")
    private String accountId;

    @JsonProperty("amount")
    private BigDecimal amount;

    @JsonProperty("currency")
    private String currency;

    @JsonProperty("transaction_date")
    private LocalDateTime transactionDate;

    @JsonProperty("value_date")
    private LocalDate valueDate;

    @JsonProperty("description")
    private String description;

    @JsonProperty("transaction_type")
    private String transactionType;

    @JsonProperty("transaction_status")
    private String transactionStatus;

    @JsonProperty("reference_number")
    private String referenceNumber;

    @JsonProperty("merchant_info")
    private MerchantInfoDTO merchantInfo;

    @JsonProperty("category")
    private String category;

    @JsonProperty("balance_after")
    private BigDecimal balanceAfter;

    @JsonProperty("fees")
    private List<FeeDTO> fees;
}
