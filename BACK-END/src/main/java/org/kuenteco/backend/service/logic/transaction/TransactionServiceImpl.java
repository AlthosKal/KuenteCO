package org.kuenteco.backend.service.logic.transaction;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.transaction.NewTransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.ProfileWithTransactionsDTO;
import org.kuenteco.backend.dto.logic.transaction.UpdateTransactionDTO;
import org.kuenteco.backend.dto.logic.transaction.UserProfilesWithTransactionsDTO;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.Transaction;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.TransactionException;
import org.kuenteco.backend.jwt.AuthCredentials;
import org.kuenteco.backend.mapper.logic.transaction.NewTransactionMapper;
import org.kuenteco.backend.mapper.logic.transaction.ProfileWithTransactionsMapper;
import org.kuenteco.backend.mapper.logic.transaction.TransactionDetailMapper;
import org.kuenteco.backend.mapper.logic.transaction.UpdateTransactionMapper;
import org.kuenteco.backend.repository.master.MasterTransactionRepository;
import org.kuenteco.backend.repository.slave.*;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class TransactionServiceImpl implements TransactionService {
    private final MasterTransactionRepository masterTransactionRepository;
    private final SlaveTransactionRepository slaveTransactionRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final SlaveCategoryRepository slaveCategoryRepository;
    private final SlaveBudgetRepository slaveBudgetRepository;
    private final TransactionDetailMapper transactionDetailMapper;
    private final NewTransactionMapper newTransactionMapper;
    private final UpdateTransactionMapper updateTransactionMapper;
    private final ProfileWithTransactionsMapper profileWithTransactionsMapper;
    private final SlaveDebtRepository slaveDebtRepository;

    @Override
    public Object getTransactions() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();
        log.info("Obteniendo transacciones para: {}", email);
        return switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new TransactionException("Usuario no encontrado"));
                if (user.getType().equals(UserType.BUSINESS)) {
                    yield getUserProfilesWithTransactions(user);
                } else if (user.getType().equals(UserType.PERSONAL)) {
                    yield getUserTransactions(user);
                } else {
                    throw new TransactionException(
                            "Tipo de usuario no soportado: " + user.getType());
                }
            }
            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new TransactionException("Perfil no encontrado"));
                yield getProfileTransactions(profile);
            }
        };
    }

    @Override
    public void addTransaction(NewTransactionDTO dto) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();
        log.info("Registrando transacciones para: {}", email);
        Transaction transaction = prepareNewTransaction(dto);

        switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new TransactionException("Usuario no encontrado"));
                transaction.setUser(user);
                masterTransactionRepository.save(transaction);
            }
            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new TransactionException("Perfil no encontrado"));
                transaction.setProfile(profile);
                masterTransactionRepository.save(transaction);
            }
            default -> throw new TransactionException("Role no encontrado " + role);
        }
    }

    @Override
    public void updateTransaction(UpdateTransactionDTO dto) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();
        log.info("Actualizando transacciones para: {}", email);
        Transaction transaction = prepareUpdateTransaction(dto);

        switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new TransactionException("Usuario no encontrado"));
                transaction.setUser(user);
                masterTransactionRepository.save(transaction);
            }

            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(
                                        () -> new TransactionException("Perfil no encontrado"));
                transaction.setProfile(profile);
                masterTransactionRepository.save(transaction);
            }
            default -> throw new TransactionException("Rol no soportado: " + role);
        }
    }

    @Override
    public void deleteTransaction(Integer id) {
        if (id == null) {
            throw new TransactionException("ID de transacción no puede ser nulo");
        }

        if (!masterTransactionRepository.existsById(id)) {
            throw new TransactionException("Transacción no encontrada con ID: " + id);
        }

        masterTransactionRepository.deleteById(id);
        log.info("Transacción eliminada con ID: {}", id);
    }

    // Métodos auxiliares
    private Object getUserTransactions(User user) {
        List<Transaction> transactions = slaveTransactionRepository.findByUser(user);

        if (transactions.isEmpty()) {
            return "No tienes transacciones registradas";
        }

        return transactionDetailMapper.toDtoList(transactions);
    }

    private UserProfilesWithTransactionsDTO getUserProfilesWithTransactions(User user) {
        // Obtener todos los perfiles del usuarío
        List<Profile> profiles = slaveProfileRepository.findByUser(user);

        if (profiles.isEmpty()) {
            log.info("No tienes perfiles registrados");
            return UserProfilesWithTransactionsDTO.builder()
                    .username(user.getUsername())
                    .email(user.getEmail())
                    .profiles(List.of())
                    .totalProfiles(0)
                    .totalTransactions(0)
                    .build();
        }

        List<ProfileWithTransactionsDTO> profilesWithTransactions =
                profiles.stream()
                        .map(
                                profile -> {
                                    List<Transaction> transactions =
                                            slaveTransactionRepository.findByProfile(profile);
                                    return profileWithTransactionsMapper.toDto(
                                            profile, transactions);
                                })
                        .toList();

        // Calcular totales
        int totalTransactions =
                profilesWithTransactions.stream()
                        .mapToInt(ProfileWithTransactionsDTO::getTransactionCount)
                        .sum();
        log.info(
                "Usuario {} tiene {} perfiles con {} transacciones totales",
                user.getEmail(),
                profiles.size(),
                totalTransactions);

        return UserProfilesWithTransactionsDTO.builder()
                .username(user.getUsername())
                .email(user.getEmail())
                .profiles(profilesWithTransactions)
                .totalProfiles(profiles.size())
                .totalTransactions(totalTransactions)
                .build();
    }

    private Object getProfileTransactions(Profile profile) {
        List<Transaction> transactions = slaveTransactionRepository.findByProfile(profile);

        if (transactions.isEmpty()) {
            return "No tienes transacciones registradas";
        }

        return transactionDetailMapper.toDtoList(transactions);
    }

    private Transaction prepareNewTransaction(NewTransactionDTO dto) {
        Transaction transaction = newTransactionMapper.toEntity(dto);
        resolveCategoryAndBudget(
                dto.getCategoryId(), dto.getBudgetId(), dto.getDebtId(), transaction);
        transaction.setTransactionDate(LocalDateTime.now());
        return transaction;
    }

    private Transaction prepareUpdateTransaction(UpdateTransactionDTO dto) {
        Transaction transaction = updateTransactionMapper.toEntity(dto);
        resolveCategoryAndBudget(
                dto.getCategoryId(), dto.getBudgetId(), dto.getDebtId(), transaction);
        return transaction;
    }

    private void resolveCategoryAndBudget(
            Integer categoryId, Integer budgetId, Integer debtId, Transaction transaction) {
        if (categoryId != null) {
            transaction.setCategory(
                    slaveCategoryRepository
                            .findById(categoryId)
                            .orElseThrow(
                                    () ->
                                            new TransactionException(
                                                    "Categoría no encontrada con ID: "
                                                            + categoryId)));
        } else {
            transaction.setCategory(null);
        }

        if (budgetId != null) {
            transaction.setBudget(
                    slaveBudgetRepository
                            .findById(budgetId)
                            .orElseThrow(
                                    () ->
                                            new TransactionException(
                                                    "Presupuesto no encontrado con ID: "
                                                            + budgetId)));
        } else {
            transaction.setBudget(null);
        }
        if (debtId != null) {
            transaction.setDebt(
                    slaveDebtRepository
                            .findById(debtId)
                            .orElseThrow(
                                    () ->
                                            new TransactionException(
                                                    "Deuda no encontrado con ID: " + debtId)));
        } else {
            transaction.setDebt(null);
        }
    }
}
