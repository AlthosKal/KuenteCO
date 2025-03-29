package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterPaymentHistory;
import org.kuenteco.backend.entity.slave.SlavePaymentHistory;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = PaySubscriptionMapper.class)
public interface PaymentHistoryMapper {

    @Mapping(source = "slavePaySubscription", target = "masterPaySubscription")
    @Mapping(target = "id", ignore = true)
    MasterPaymentHistory slaveToMaster(SlavePaymentHistory slavePaymentHistory);

    @Mapping(source = "masterPaySubscription", target = "slavePaySubscription")
    SlavePaymentHistory masterToSlave(MasterPaymentHistory masterPaymentHistory);
}
