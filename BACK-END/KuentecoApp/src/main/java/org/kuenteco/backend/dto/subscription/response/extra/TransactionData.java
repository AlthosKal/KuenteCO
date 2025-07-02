package org.kuenteco.backend.dto.subscription.response.extra;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionData {
    private String id;
    @JsonProperty("created_at")
    private String createdAt;
    @JsonProperty("finalized_at")
    private String finalizedAt;
    @JsonProperty("amount_in_cents")
    private Long amountInCents;
    private String reference;
    @JsonProperty("customer_email")
    private String customerEmail;
    private String currency;
    @JsonProperty("payment_method_type")
    private String paymentMethodType;
    @JsonProperty("payment_method")
    private PaymentMethodData paymentMethod;
    private String status;
    @JsonProperty("status_message")
    private String statusMessage;
    @JsonProperty("merchant")
    private MerchantData merchant;
}
