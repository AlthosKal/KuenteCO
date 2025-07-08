package org.kuenteco.backend.mapper.logic.transaction.bancolombia;

import org.kuenteco.backend.dto.logic.transaction.bancolombia.*;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.enums.TransactionType;
import org.mapstruct.*;

import java.math.BigDecimal;
import java.util.List;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface BancolombiaMapper {

    // Mapping de cuentas
    @Mapping(target = "accountId", source = "accountId")
    @Mapping(target = "accountNumber", source = "accountNumber")
    @Mapping(target = "accountType", source = "accountType")
    @Mapping(target = "accountName", source = "accountName")
    @Mapping(target = "currency", source = "currency")
    @Mapping(target = "status", source = "status")
    @Mapping(target = "balance", source = "balance")
    @Mapping(target = "openingDate", source = "openingDate")
    @Mapping(target = "lastTransactionDate", source = "lastTransactionDate")
    @Mapping(target = "bankName", source = "bankName")
    AccountDTO toAccountDto(AccountDTO source);

    // Mapping de transacciones de Bancolombia a transacciones internas
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "user", source = "user")
    @Mapping(target = "profile", ignore = true)
    @Mapping(target = "category", ignore = true)
    @Mapping(target = "budget", ignore = true)
    @Mapping(target = "debt", ignore = true)
    @Mapping(target = "amount", source = "bancolombiaTransaction.amount")
    @Mapping(target = "transactionDate", source = "bancolombiaTransaction.transactionDate")
    @Mapping(target = "description", source = "bancolombiaTransaction", qualifiedByName = "mapDescription")
    Transaction toInternalTransaction(TransactionDTO bancolombiaTransaction, User user);

    @Named("mapDescription")
    default DescriptionTransaction mapDescription(TransactionDTO bancolombiaTransaction) {
        if (bancolombiaTransaction == null) {
            return null;
        }

        DescriptionTransaction description = new DescriptionTransaction();
        description.setName(bancolombiaTransaction.getDescription());
        description.setDescription(buildDetailedDescription(bancolombiaTransaction));
        description.setType(mapTransactionType(bancolombiaTransaction.getAmount()));

        return description;
    }

    default String buildDetailedDescription(TransactionDTO transaction) {
        StringBuilder desc = new StringBuilder();
        desc.append("Transacción Bancolombia - ");
        desc.append(transaction.getDescription());

        if (transaction.getMerchantInfo() != null) {
            desc.append(" | Comercio: ").append(transaction.getMerchantInfo().getMerchantName());
            if (transaction.getMerchantInfo().getLocation() != null) {
                desc.append(" | Ubicación: ").append(transaction.getMerchantInfo().getLocation());
            }
        }

        if (transaction.getReferenceNumber() != null) {
            desc.append(" | Ref: ").append(transaction.getReferenceNumber());
        }

        return desc.toString();
    }

    default TransactionType mapTransactionType(BigDecimal amount) {
        if (amount == null) {
            return TransactionType.EXPENSE;
        }
        return amount.compareTo(BigDecimal.ZERO) >= 0 ? TransactionType.INCOME : TransactionType.EXPENSE;
    }

    // Mapping de listas
    List<AccountDTO> toAccountDtoList(List<AccountDTO> accounts);
    List<TransactionDTO> toTransactionDtoList(List<TransactionDTO> transactions);
    List<Transaction> toInternalTransactionList(List<TransactionDTO> bancolombiaTransactions, User user);

    // Mapping de balance
    @Mapping(target = "available", source = "available")
    @Mapping(target = "current", source = "current")
    @Mapping(target = "creditLimit", source = "creditLimit")
    @Mapping(target = "lastUpdate", source = "lastUpdate")
    BalanceDTO toBalanceDto(BalanceDTO source);

    // Mapping de información de comerciante
    @Mapping(target = "merchantName", source = "merchantName")
    @Mapping(target = "merchantId", source = "merchantId")
    @Mapping(target = "merchantCategory", source = "merchantCategory")
    @Mapping(target = "location", source = "location")
    MerchantInfoDTO toMerchantInfoDto(MerchantInfoDTO source);

    // Mapping de resumen de transacciones
    @Mapping(target = "totalIncome", source = "totalIncome")
    @Mapping(target = "totalExpense", source = "totalExpense")
    @Mapping(target = "netAmount", source = "netAmount")
    @Mapping(target = "transactionCount", source = "transactionCount")
    @Mapping(target = "dateRange", source = "dateRange")
    TransactionSummaryDTO toTransactionSummaryDto(TransactionSummaryDTO source);
}
