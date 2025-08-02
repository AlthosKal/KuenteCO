package com.example.back_end.mapper;

import com.example.back_end.connector.rest.transaction.ProfileWithTransactionsDTO;
import com.example.back_end.connector.rest.transaction.TransactionDetailDTO;
import com.example.back_end.connector.rest.transaction.TransactionSummaryDTO;
import com.example.back_end.connector.rest.transaction.UserProfilesWithTransactionsDTO;
import com.example.back_end.enums.TransactionType;
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import org.mapstruct.Mapper;
import org.mapstruct.Named;
import org.springframework.stereotype.Component;

@Mapper(componentModel = "spring")
@Component
public interface TransactionMapper {

    @Named("convertToTransactionSummaryList")
    default List<TransactionSummaryDTO> convertToTransactionSummaryList(List<?> list) {
        if (list == null || list.isEmpty()) {
            return List.of();
        }

        return list.stream()
                .filter(UserProfilesWithTransactionsDTO.class::isInstance)
                .map(UserProfilesWithTransactionsDTO.class::cast)
                .filter(
                        userProfile ->
                                userProfile.getProfiles() != null
                                        && !userProfile.getProfiles().isEmpty())
                .flatMap(
                        userProfile ->
                                userProfile.getProfiles().stream()
                                        .filter(
                                                profile ->
                                                        profile.getTransactions() != null
                                                                && !profile.getTransactions()
                                                                        .isEmpty())
                                        .flatMap(
                                                profile ->
                                                        profile.getTransactions().stream()
                                                                .map(
                                                                        transaction ->
                                                                                mapTransactionToSummary(
                                                                                        userProfile,
                                                                                        profile,
                                                                                        transaction))))
                .collect(
                        Collectors.groupingBy(
                                TransactionSummaryDTO::getCategoryName, Collectors.toList()))
                .entrySet()
                .stream()
                .map(entry -> aggregateTransactionsByCategory(entry.getKey(), entry.getValue()))
                .collect(Collectors.toList());
    }

    private TransactionSummaryDTO mapTransactionToSummary(
            UserProfilesWithTransactionsDTO userProfile,
            ProfileWithTransactionsDTO profile,
            TransactionDetailDTO transaction) {

        String categoryName =
                transaction.getDescription() != null
                                && transaction.getDescription().getDescription() != null
                        ? transaction.getDescription().getDescription()
                        : "General";

        return TransactionSummaryDTO.builder()
                .ownerUserId(userProfile.getUsername())
                .transactionOwnerType("USER")
                .profileId(null) // No hay ID de perfil en ProfileWithTransactionsDTO
                .transactionName(categoryName)
                .categoryName(categoryName)
                .budgetName(null) // Podrías mapear si tienes esta información
                .debtName(null) // Podrías mapear si tienes esta información
                .transactionCount(1L)
                .incomeCount(transaction.getType() == TransactionType.INCOME ? 1L : 0L)
                .expenseCount(transaction.getType() == TransactionType.EXPENSE ? 1L : 0L)
                .totalIncome(
                        transaction.getType() == TransactionType.INCOME
                                ? transaction.getAmount()
                                : BigDecimal.ZERO)
                .totalExpenses(
                        transaction.getType() == TransactionType.EXPENSE
                                ? transaction.getAmount()
                                : BigDecimal.ZERO)
                .netAmount(
                        transaction.getType() == TransactionType.INCOME
                                ? transaction.getAmount()
                                : transaction.getAmount().negate())
                .firstTransactionDate(transaction.getTimestamp())
                .lastTransactionDate(transaction.getTimestamp())
                .build();
    }

    private TransactionSummaryDTO aggregateTransactionsByCategory(
            String categoryName, List<TransactionSummaryDTO> transactions) {
        BigDecimal totalIncome =
                transactions.stream()
                        .map(TransactionSummaryDTO::getTotalIncome)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalExpenses =
                transactions.stream()
                        .map(TransactionSummaryDTO::getTotalExpenses)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

        long totalIncomeCount =
                transactions.stream().mapToLong(TransactionSummaryDTO::getIncomeCount).sum();

        long totalExpenseCount =
                transactions.stream().mapToLong(TransactionSummaryDTO::getExpenseCount).sum();

        // Obtener primer usuario para datos de referencia
        TransactionSummaryDTO firstTransaction = transactions.get(0);

        return TransactionSummaryDTO.builder()
                .ownerUserId(firstTransaction.getOwnerUserId())
                .transactionOwnerType("AGGREGATED")
                .profileId(firstTransaction.getProfileId())
                .transactionName(categoryName + " - Summary")
                .categoryName(categoryName)
                .budgetName(firstTransaction.getBudgetName())
                .debtName(firstTransaction.getDebtName())
                .transactionCount((long) transactions.size())
                .incomeCount(totalIncomeCount)
                .expenseCount(totalExpenseCount)
                .totalIncome(totalIncome)
                .totalExpenses(totalExpenses)
                .netAmount(totalIncome.subtract(totalExpenses))
                .firstTransactionDate(
                        transactions.stream()
                                .map(TransactionSummaryDTO::getFirstTransactionDate)
                                .min(Comparator.naturalOrder())
                                .orElse(null))
                .lastTransactionDate(
                        transactions.stream()
                                .map(TransactionSummaryDTO::getLastTransactionDate)
                                .max(Comparator.naturalOrder())
                                .orElse(null))
                .build();
    }
}
