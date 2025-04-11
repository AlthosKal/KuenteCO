package org.kuenteco.backend.dto.account;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.AccountType;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AccountDetailDTO {
    private Integer id;
    private String name;
    private AccountType type;
}
