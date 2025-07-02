package org.kuenteco.backend.dto.subscription.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.subscription.request.extra.WompiCustomerData;
import org.kuenteco.backend.dto.subscription.request.extra.WompiPaymentMethod;
import org.kuenteco.backend.dto.subscription.request.extra.WompiShippingAddress;
import org.kuenteco.backend.enums.CurrencyType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WompiTransactionRequestDTO {
    @JsonProperty("amount_in_cents")
    private Long amountInCents;
    private CurrencyType currency;
    private String signature;
    @JsonProperty("customer_email")
    private String customerEmail;
    private String reference;
    @JsonProperty("payment_method")
    private WompiPaymentMethod paymentMethod;
    @JsonProperty("redirect_url")
    private String redirectUrl;
    @JsonProperty("shipping_address")
    private WompiShippingAddress shippingAddress;
    @JsonProperty("customer_data")
    private WompiCustomerData customerData;
}
