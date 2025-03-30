package org.kuenteco.backend.service.account;

import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.entity.master.MasterAccount;
import org.kuenteco.backend.entity.master.MasterSubscription;
import org.kuenteco.backend.entity.master.MasterUser;
import org.kuenteco.backend.entity.slave.SlaveAccount;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.exception.exceptions.AccountException;
import org.kuenteco.backend.mapper.entity.AccountMapper;
import org.kuenteco.backend.mapper.entity.UserMapper;
import org.kuenteco.backend.repository.master.MasterAccountRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveAccountRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.jwt.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

@Service
@NoArgsConstructor
public class AccountServiceImpl implements AccountService {
    private UserService userService;
    private MasterAccountRepository masterAccountRepository;
    private SlaveAccountRepository slaveAccountRepository;
    private SlaveUserRepository slaveUserRepository;
    private MasterSubscription masterSubscription;
    private UserMapper userMapper;
    private AccountMapper accountMapper;
    private MasterUserRepository masterUserRepository;

    @Autowired
    public AccountServiceImpl(UserService userService, MasterAccountRepository masterAccountRepository,
                              SlaveAccountRepository slaveAccountRepository, SlaveUserRepository slaveUserRepository,
                              UserMapper userMapper, AccountMapper accountMapper, MasterUserRepository masterUserRepository) {
        this.userService = userService;
        this.masterAccountRepository = masterAccountRepository;
        this.slaveAccountRepository = slaveAccountRepository;
        this.slaveUserRepository = slaveUserRepository;
        this.userMapper = userMapper;
        this.accountMapper = accountMapper;
        this.masterUserRepository = masterUserRepository;
    }

    public List<SlaveAccount> getAccounts() {
        // Obtener el usuario autenticado
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        SlaveUser user = slaveUserRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        // Obtener las cuentas del usuario
        List<SlaveAccount> slaveAccounts = slaveAccountRepository.findBySlaveUser(user);

        // Verificar si las cuentas están vacías o nulas
        if (slaveAccounts == null || slaveAccounts.isEmpty()) {
            throw new IllegalStateException("No hay cuentas existentes");
        }

        // Devolver las cuentas del usuario
        return slaveAccounts;
    }

    public void registerAccount(NewAccountDTO newAccountDTO, String username) {
        // Obtener el usuario autenticado
        MasterUser user = masterUserRepository.findByEmail(username)
                .orElseThrow(() -> new AccountException(String.valueOf("Usuario no encontrado")));

        if (existsByAccountName(newAccountDTO.getName()) && masterSubscription.getState() == State.INACTIVE)
            throw new AccountException(String.valueOf(new ApiMessage("Necesitas tener una cuenta con una subscripción activa")));

        if (existsByAccountName(newAccountDTO.getName()))
            throw new AccountException(String.valueOf("Cuenta con este nombre ya existente"));

        MasterAccount account = new MasterAccount();
        account.setMasterUser(user);
        account.setName(newAccountDTO.getName());
        account.setType(newAccountDTO.getType());
        account.setBalance(newAccountDTO.getGetInitialBalance());
        account.setStartDate(Timestamp.valueOf(LocalDateTime.now()));
        masterAccountRepository.save(account);
    }

    public boolean existsByAccountName(String name) {
        return slaveAccountRepository.existsByName(name);
    }

    public void deleteAccount(MasterAccount account) {
        masterAccountRepository.delete(account);
    }
}
