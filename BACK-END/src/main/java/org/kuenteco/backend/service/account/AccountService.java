package org.kuenteco.backend.service.account;

import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.entity.Account;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

public interface AccountService {
    List<Account> getAccounts();

    void registerAccount(NewAccountDTO newAccountDTO, String username) throws IOException;

    void deleteAccount(Account account) throws IOException;

    static final Logger log = LoggerFactory.getLogger(AccountService.class);
}
