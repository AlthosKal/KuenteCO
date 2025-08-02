package com.example.back_end.connector.rest.transaction;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetTransactionDTO {
    private Integer id;
    private DescriptionTransaction description;
    private Integer amount;
}
