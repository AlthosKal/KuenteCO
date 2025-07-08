package com.example.back_end.KuentecoChat.connector.rest;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetTransactionDTO {
    private Integer id;
    private TransactionDescription description;
    private Integer amount;
}
