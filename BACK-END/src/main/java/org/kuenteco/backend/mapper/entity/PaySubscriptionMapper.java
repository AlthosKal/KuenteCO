package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterPaySubscription;
import org.kuenteco.backend.entity.master.MasterSubscription;
import org.kuenteco.backend.entity.slave.SlavePaySubscription;
import org.kuenteco.backend.entity.slave.SlaveSubscription;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.mapper.entity.extra.ExtraClassesMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

@Mapper(componentModel = "spring", uses = { SubscriptionMapper.class, ExtraClassesMapper.class })
public interface PaySubscriptionMapper {

    @Mapping(source = "slaveSubscription", target = "masterSubscription", qualifiedByName = "mapSlaveToMasterSubscription")
    @Mapping(source = "payMethod", target = "payMethod")
    @Mapping(target = "id", ignore = true)
    MasterPaySubscription slaveToMaster(SlavePaySubscription slavePaySubscription);

    @Mapping(source = "masterSubscription", target = "slaveSubscription", qualifiedByName = "mapMasterToSlaveSubscription")
    @Mapping(source = "payMethod", target = "payMethod")
    SlavePaySubscription masterToSlave(MasterPaySubscription masterPaySubscription);

    @Named("mapSlaveToMasterSubscription")
    default MasterSubscription mapSlaveToMasterSubscription(SlaveSubscription slaveSubscription) {
        if (slaveSubscription == null) {
            return null;
        }

        MasterSubscription masterSubscription = new MasterSubscription();
        masterSubscription.setType(SubscriptionType.valueOf(slaveSubscription.getType()));
        masterSubscription.setState(slaveSubscription.getState());
        masterSubscription.setStartDate(slaveSubscription.getStartDate());
        masterSubscription.setExpirationDate(slaveSubscription.getExpirationDate());
        // Nota: account no se mapea aquí para evitar recursión infinita
        return masterSubscription;
    }

    @Named("mapMasterToSlaveSubscription")
    default SlaveSubscription mapMasterToSlaveSubscription(MasterSubscription masterSubscription) {
        if (masterSubscription == null) {
            return null;
        }

        SlaveSubscription slaveSubscription = new SlaveSubscription();
        slaveSubscription.setType(String.valueOf(masterSubscription.getType()));
        slaveSubscription.setState(masterSubscription.getState());
        slaveSubscription.setStartDate(masterSubscription.getStartDate());
        slaveSubscription.setExpirationDate(masterSubscription.getExpirationDate());
        // Nota: account no se mapea aquí para evitar recursión infinita
        return slaveSubscription;
    }
}