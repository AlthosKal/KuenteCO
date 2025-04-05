package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterTransaction;
import org.kuenteco.backend.entity.slave.SlaveTransaction;
import org.kuenteco.backend.mapper.entity.extra.ExtraClassesMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = { AccountMapper.class, CategoryMapper.class, ExtraClassesMapper.class })
public interface TransactionMapper {

    @Mapping(target = "id", ignore = true)
    MasterTransaction slaveToMaster(SlaveTransaction slaveTransaction);

    SlaveTransaction masterToSlave(MasterTransaction masterTransaction);
}
