package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterTransaction;
import org.kuenteco.backend.entity.slave.SlaveTransaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = { AccountMapper.class, CategoryMapper.class })
public interface TransactionMapper {

    @Mapping(source = "slaveAccount", target = "masterAccount")
    @Mapping(source = "slaveCategory", target = "masterCategory")
    @Mapping(target = "id", ignore = true)
    MasterTransaction slaveToMaster(SlaveTransaction slaveTransaction);

    @Mapping(source = "masterAccount", target = "slaveAccount")
    @Mapping(source = "masterCategory", target = "slaveCategory")
    SlaveTransaction masterToSlave(MasterTransaction masterTransaction);
}
