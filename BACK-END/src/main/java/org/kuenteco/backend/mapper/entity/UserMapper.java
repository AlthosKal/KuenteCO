package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterRole;
import org.kuenteco.backend.entity.master.MasterUser;
import org.kuenteco.backend.entity.slave.SlaveRole;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

@Mapper(componentModel = "spring")
public interface UserMapper {

    @Mapping(source = "slaveRole", target = "role", qualifiedByName = "slaveRoleToMasterRole")
    @Mapping(target = "id", expression = "java(java.util.UUID.randomUUID().toString())")
    MasterUser slaveToMaster(SlaveUser slaveUser);

    @Mapping(source = "role", target = "slaveRole", qualifiedByName = "masterRoleToSlaveRole")
    SlaveUser masterToSlave(MasterUser masterUser);

    @Named("slaveRoleToMasterRole")
    default MasterRole slaveRoleToMasterRole(SlaveRole slaveRole) {
        if (slaveRole == null)
            return null;
        MasterRole masterRole = new MasterRole();
        masterRole.setName(slaveRole.getName());
        return masterRole;
    }

    @Named("masterRoleToSlaveRole")
    default SlaveRole masterRoleToSlaveRole(MasterRole masterRole) {
        if (masterRole == null)
            return null;
        SlaveRole slaveRole = new SlaveRole();
        slaveRole.setId(masterRole.getId());
        slaveRole.setName(masterRole.getName());
        return slaveRole;
    }
}
