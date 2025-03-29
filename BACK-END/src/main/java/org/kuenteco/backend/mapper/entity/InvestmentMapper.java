package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterInvestment;
import org.kuenteco.backend.entity.slave.SlaveInvestment;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = AccountMapper.class)
public interface InvestmentMapper {

    @Mapping(source = "slaveAccount", target = "masterAccount")
    @Mapping(target = "id", ignore = true)
    MasterInvestment slaveToMaster(SlaveInvestment slaveInvestment);

    @Mapping(source = "masterAccount", target = "slaveAccount")
    SlaveInvestment masterToSlave(MasterInvestment masterInvestment);
}
