package org.kuenteco.backend.dto.subscription.wompi.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.subscription.wompi.request.extra.WompiCustomerDataDTO;
import org.kuenteco.backend.dto.subscription.wompi.request.extra.WompiPaymentMethodDTO;
import org.kuenteco.backend.dto.subscription.wompi.request.extra.WompiShippingAddressDTO;
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
    private WompiPaymentMethodDTO paymentMethod;

    @JsonProperty("shipping_address")
    private WompiShippingAddressDTO shippingAddress;

    @JsonProperty("customer_data")
    private WompiCustomerDataDTO customerData;
}
