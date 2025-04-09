package org.kuenteco.backend.mapper;

import org.kuenteco.backend.dto.account.AccountDetailDTO;
import org.kuenteco.backend.entity.Account;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface AccountDetailMapper {
    List<AccountDetailDTO> toDto(List<Account> account);
}
