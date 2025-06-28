package org.kuenteco.backend.service.logic.transaction;

import java.sql.Timestamp;
import java.time.Instant;
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
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.TransactionException;
import org.kuenteco.backend.mapper.logic.transaction.NewTransactionMapper;
import org.kuenteco.backend.mapper.logic.transaction.ProfileWithTransactionsMapper;
import org.kuenteco.backend.mapper.logic.transaction.TransactionDetailMapper;
import org.kuenteco.backend.mapper.logic.transaction.UpdateTransactionMapper;
import org.kuenteco.backend.repository.master.MasterTransactionRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveTransactionRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
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

    @Override
    public Object getTransactions() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Obteniendo transacciones para: {}", email);

        // Primero intenta buscar como usuario
        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            if (user.getType().equals(UserType.BUSINESS)) {
                log.info("Usuario encontrado {}", email);
                return getUserProfilesWithTransactions(user);
            } else if (user.getType().equals(UserType.PERSONAL)) {
                log.info("Usuario encontrado: {}", email);
                return getUserTransactions(user);
            }
        }

        // Si no es usuario, busca como perfil
        Profile profile = slaveProfileRepository.findByEmail(email).orElse(null);
        if (profile != null) {
            log.info("Perfil encontrado: {}", email);
            return getProfileTransactions(profile);
        }

        throw new TransactionException("Usuario o perfil no encontrado: " + email);
    }

    @Override
    public void addTransaction(NewTransactionDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Transaction transaction = newTransactionMapper.toEntity(dto);

        // Resolver Category y Budget desde los ID
        if (dto.getCategoryId() != null) {
            transaction.setCategory(
                    slaveCategoryRepository
                            .findById(dto.getCategoryId())
                            .orElseThrow(
                                    () ->
                                            new TransactionException(
                                                    "Categoría no encontrada con ID: "
                                                            + dto.getCategoryId())));
        }

        if (dto.getBudgetId() != null) {
            transaction.setBudget(
                    slaveBudgetRepository
                            .findById(dto.getBudgetId())
                            .orElseThrow(
                                    () ->
                                            new TransactionException(
                                                    "Presupuesto no encontrado con ID: "
                                                            + dto.getBudgetId())));
        }

        // Primero intenta buscar como usuario personal
        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            log.info("Registrando transacción para usuario personal: {}", email);
            transaction.setUser(user);
            transaction.setTransactionDate(Timestamp.from(Instant.now()));
            masterTransactionRepository.save(transaction);
            return;
        }

        // Si no es usuario personal, busca como perfil de negocio
        Profile profile = slaveProfileRepository.findByEmail(email).orElse(null);
        if (profile != null) {
            log.info("Registrando transacción para perfil de negocio: {}", email);
            transaction.setProfile(profile);
            transaction.setTransactionDate(Timestamp.from(Instant.now()));
            masterTransactionRepository.save(transaction);
            return;
        }

        throw new TransactionException("Usuario o perfil no encontrado: " + email);
    }

    @Override
    public void updateTransaction(UpdateTransactionDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Transaction transaction = updateTransactionMapper.toEntity(dto);

        // Resolver Category y Budget desde los ID
        if (dto.getCategoryId() != null) {
            transaction.setCategory(
                    slaveCategoryRepository
                            .findById(dto.getCategoryId())
                            .orElseThrow(
                                    () ->
                                            new TransactionException(
                                                    "Categoría no encontrada con ID: "
                                                            + dto.getCategoryId())));
        }

        if (dto.getBudgetId() != null) {
            transaction.setBudget(
                    slaveBudgetRepository
                            .findById(dto.getBudgetId())
                            .orElseThrow(
                                    () ->
                                            new TransactionException(
                                                    "Presupuesto no encontrado con ID: "
                                                            + dto.getBudgetId())));
        }

        // Primero intenta buscar como usuario personal
        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            log.info("Actualizando transacción para usuario personal: {}", email);
            transaction.setUser(user);
            masterTransactionRepository.save(transaction);
            return;
        }

        // Si no es usuario personal, busca como perfil de negocio
        Profile profile = slaveProfileRepository.findByEmail(email).orElse(null);
        if (profile != null) {
            log.info("Actualizando transacción para perfil de negocio: {}", email);
            transaction.setProfile(profile);
            masterTransactionRepository.save(transaction);
            return;
        }

        throw new TransactionException("Usuario o perfil no encontrado: " + email);
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
}
