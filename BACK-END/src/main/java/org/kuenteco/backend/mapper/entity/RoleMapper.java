package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterRole;
import org.kuenteco.backend.entity.slave.SlaveRole;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface RoleMapper {

    @Mapping(target = "id", ignore = true) // ID se genera en master
    MasterRole slaveToMaster(SlaveRole slaveRole);

    SlaveRole masterToSlave(MasterRole masterRole);
}
