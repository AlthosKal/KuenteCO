package org.kuenteco.backend.mapper.dto;

import org.kuenteco.backend.dto.account.AccountDetailDTO;
import org.kuenteco.backend.entity.slave.SlaveAccount;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface AccountDetailMapper {
    @Mapping(target = "name", source = "slaveAccount.name")
    @Mapping(target = "type", source = "slaveAccount.type")
    @Mapping(target = "balance", source = "slaveAccount.balance")
    List<AccountDetailDTO> toDto(List<SlaveAccount> slaveAccount);
}
