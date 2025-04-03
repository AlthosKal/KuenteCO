package org.kuenteco.backend.service.account;

import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.account.AccountDetailDTO;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.entity.master.MasterAccount;
import org.kuenteco.backend.entity.master.MasterSubscription;
import org.kuenteco.backend.entity.master.MasterUser;
import org.kuenteco.backend.entity.slave.SlaveAccount;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.exception.exceptions.AccountException;
import org.kuenteco.backend.mapper.dto.AccountDetailMapper;
import org.kuenteco.backend.mapper.dto.NewAccountMapper;
import org.kuenteco.backend.mapper.entity.AccountMapper;
import org.kuenteco.backend.mapper.entity.UserMapper;
import org.kuenteco.backend.repository.master.MasterAccountRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveAccountRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.auth.UserService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AccountServiceImpl implements AccountService {
    private final MasterAccountRepository masterAccountRepository;
    private final SlaveAccountRepository slaveAccountRepository;
    private final SlaveUserRepository slaveUserRepository;
    private MasterSubscription masterSubscription;
    private final NewAccountMapper newAccountMapper;
    private final MasterUserRepository masterUserRepository;
    private final AccountDetailMapper accountDetailMapper;

    public List<AccountDetailDTO> getAccounts() {
        // Obtener el usuario autenticado
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        SlaveUser user = slaveUserRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        // Obtener las cuentas del usuario
        List<SlaveAccount> slaveAccount = slaveAccountRepository.findBySlaveUser(user);

        // Verificar si las cuentas están vacías o nulas
        if (slaveAccount == null || slaveAccount.isEmpty()) {
            throw new IllegalStateException("No hay cuentas existentes");
        }

        // Devolver las cuentas del usuario
        return accountDetailMapper.toDto(slaveAccount);
    }

    public void registerAccount(NewAccountDTO newAccountDTO, String username) {
        MasterUser user = masterUserRepository.findByEmail(username)
                .orElseThrow(() -> new AccountException("Usuario no encontrado"));

        if (existsByAccountName(newAccountDTO.getName()) && masterSubscription.getState() == State.INACTIVE)
            throw new AccountException("Necesitas tener una cuenta con una subscripción activa");

        if (existsByAccountName(newAccountDTO.getName()))
            throw new AccountException("Cuenta con este nombre ya existente");

        MasterAccount account = newAccountMapper.toMasterAccount(newAccountDTO);
        account.setMasterUser(user);

        masterAccountRepository.save(account);
    }

    public boolean existsByAccountName(String name) {
        return slaveAccountRepository.existsByName(name);
    }

    public void deleteAccount(MasterAccount account) {
        masterAccountRepository.delete(account);
    }
}
