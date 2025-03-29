package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterSubscription;
import org.kuenteco.backend.entity.slave.SlaveSubscription;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = AccountMapper.class)
public interface SubscriptionMapper {

    @Mapping(source = "slaveAccount", target = "masterAccount")
    @Mapping(target = "id", ignore = true)
    MasterSubscription slaveToMaster(SlaveSubscription slaveSubscription);

    @Mapping(source = "masterAccount", target = "slaveAccount")
    SlaveSubscription masterToSlave(MasterSubscription masterSubscription);
}
