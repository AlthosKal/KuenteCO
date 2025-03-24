package org.kuenteco.backend.service.account;

import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.entity.Account;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.exception.exceptions.AccountException;
import org.kuenteco.backend.repository.AccountRepository;
import org.kuenteco.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@NoArgsConstructor
public class AccountServiceImpl implements AccountService {
    private AccountRepository accountRepository;

    private UserRepository userRepository;
    private Subscription subscription;

    @Autowired
    public AccountServiceImpl(AccountRepository accountRepository, UserRepository userRepository) {
        this.accountRepository = accountRepository;
        this.userRepository = userRepository;
    }

    public List<Account> getAccounts() {
        // Obtener el usuario autenticado
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // Obtener las cuentas del usuario
        List<Account> accounts = accountRepository.findByUser(user);

        // Verificar si las cuentas están vacías o nulas
        if (accounts == null || accounts.isEmpty()) {
            throw new IllegalStateException("Accounts not found");
        }

        // Devolver las cuentas del usuario
        return accounts;
    }

    public void registerAccount(NewAccountDTO newAccountDTO, String username) {
        // Obtener el usuario autenticado
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new AccountException(String.valueOf("User not found")));

        if (existsByAccountName(newAccountDTO.getName()) && subscription.getState() == State.INACTIVE)
            throw new AccountException(String.valueOf(new ApiMessage("You need pay one subscription")));

        if (existsByAccountName(newAccountDTO.getName()))
            throw new AccountException(String.valueOf("Account already exists"));

        Account account = new Account();
        account.setUser(user);
        account.setName(newAccountDTO.getName());
        account.setType(newAccountDTO.getType());
        account.setBalance(newAccountDTO.getGetInitialBalance());
        account.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        accountRepository.save(account);
    }

    public boolean existsByAccountName(String name) {
        return accountRepository.existsByName(name);
    }

    public void deleteAccount(Account account) {
        accountRepository.delete(account);
    }
}
