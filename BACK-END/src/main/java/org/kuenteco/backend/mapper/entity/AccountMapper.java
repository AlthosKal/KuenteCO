package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterAccount;
import org.kuenteco.backend.entity.slave.SlaveAccount;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring", uses = UserMapper.class)
public interface AccountMapper {

    @Mapping(source = "slaveUser", target = "masterUser")
    @Mapping(target = "id", ignore = true)
    MasterAccount slaveToMaster(SlaveAccount slaveAccount);

    @Mapping(source = "masterUser", target = "slaveUser")
    SlaveAccount masterToSlave(MasterAccount masterAccount);

    // Métodos para mapear listas
    List<MasterAccount> slaveToMasterList(List<SlaveAccount> slaveAccounts);

    List<SlaveAccount> masterToSlaveList(List<MasterAccount> masterAccounts);
}
