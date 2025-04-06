package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.account.AccountDetailDTO;
import org.kuenteco.backend.entity.Account;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface AccountDetailMapper {
    @Mapping(target = "name", source = "slaveAccount.name")
    @Mapping(target = "type", source = "slaveAccount.type")
    @Mapping(target = "balance", source = "slaveAccount.balance")
    List<AccountDetailDTO> toDto(List<Account> account);
}
