package org.kuenteco.backend.service.account;

import org.kuenteco.backend.dto.account.AccountDetailDTO;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.entity.master.MasterAccount;

import java.io.IOException;
import java.util.List;

public interface AccountService {
    List<AccountDetailDTO> getAccounts();

    void registerAccount(NewAccountDTO newAccountDTO, String username) throws IOException;

    void deleteAccount(MasterAccount account) throws IOException;
}
