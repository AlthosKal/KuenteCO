package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterDebt;
import org.kuenteco.backend.entity.slave.SlaveDebt;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = AccountMapper.class)
public interface DebtMapper {

    @Mapping(source = "slaveAccount", target = "masterAccount")
    @Mapping(target = "id", ignore = true)
    MasterDebt slaveToMaster(SlaveDebt slaveDebt);

    @Mapping(source = "masterAccount", target = "slaveAccount")
    SlaveDebt masterToSlave(MasterDebt masterDebt);
}
