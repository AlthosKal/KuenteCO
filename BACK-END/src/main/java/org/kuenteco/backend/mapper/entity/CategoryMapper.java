package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterCategory;
import org.kuenteco.backend.entity.slave.SlaveCategory;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = AccountMapper.class)
public interface CategoryMapper {

    @Mapping(source = "slaveAccount", target = "masterAccount")
    @Mapping(target = "id", ignore = true)
    MasterCategory slaveToMaster(SlaveCategory slaveCategory);

    @Mapping(source = "masterAccount", target = "slaveAccount")
    SlaveCategory masterToSlave(MasterCategory masterCategory);
}
