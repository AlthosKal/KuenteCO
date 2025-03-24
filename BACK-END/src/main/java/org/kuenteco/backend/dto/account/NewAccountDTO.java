package org.kuenteco.backend.dto.account;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.AccountType;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewAccountDTO {
    private String name;
    private AccountType type;
    private BigDecimal getInitialBalance;
}
