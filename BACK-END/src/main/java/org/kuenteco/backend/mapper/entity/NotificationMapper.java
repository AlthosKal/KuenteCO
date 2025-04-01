package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterNotification;
import org.kuenteco.backend.entity.slave.SlaveNotification;
import org.kuenteco.backend.mapper.entity.extra.ExtraClassesMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = { AccountMapper.class, ExtraClassesMapper.class })
public interface NotificationMapper {

    @Mapping(source = "slaveAccount", target = "masterAccount")
    @Mapping(target = "id", ignore = true)
    MasterNotification slaveToMaster(SlaveNotification slaveNotification);

    @Mapping(source = "masterAccount", target = "slaveAccount")
    SlaveNotification masterToSlave(MasterNotification masterNotification);
}
