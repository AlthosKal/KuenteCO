package com.example.back_end.connector.rest.transaction;

import com.example.back_end.enums.TransactionType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionTransaction {
    private String description;

    private TransactionType type;
}
