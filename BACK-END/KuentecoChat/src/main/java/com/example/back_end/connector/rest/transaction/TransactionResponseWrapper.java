package com.example.back_end.connector.rest.transaction;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionResponseWrapper {

    @JsonProperty("responseType")
    private String responseType; // "USER_PROFILES", "TRANSACTION_LIST", "MESSAGE"

    @JsonProperty("userProfiles")
    private UserProfilesWithTransactionsDTO userProfiles;

    @JsonProperty("transactionList")
    private java.util.List<TransactionDetailDTO> transactionList;

    @JsonProperty("message")
    private String message;

    // Método para determinar el tipo de respuesta
    public ResponseType getType() {
        if (userProfiles != null) {
            return ResponseType.USER_PROFILES;
        } else if (transactionList != null && !transactionList.isEmpty()) {
            return ResponseType.TRANSACTION_LIST;
        } else if (message != null) {
            return ResponseType.MESSAGE;
        }
        return ResponseType.UNKNOWN;
    }

    public enum ResponseType {
        USER_PROFILES,
        TRANSACTION_LIST,
        MESSAGE,
        UNKNOWN
    }
}