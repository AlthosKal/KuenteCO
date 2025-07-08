package com.example.back_end.KuentecoChat.connector.rest;

import com.example.back_end.KuentecoChat.enums.TransactionType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TransactionDescription {
    private String name;
    private Timestamp registrationDate;
    private TransactionType type;
}
