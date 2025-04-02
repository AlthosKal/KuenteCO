package org.kuenteco.backend.mapper.entity;

import org.kuenteco.backend.entity.master.MasterBudget;
import org.kuenteco.backend.entity.slave.SlaveBudget;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = { AccountMapper.class, CategoryMapper.class })
public interface BudgetMapper {

    @Mapping(source = "account", target = "masterAccount")
    @Mapping(source = "category", target = "masterCategory")
    @Mapping(target = "id", ignore = true)
    MasterBudget slaveToMaster(SlaveBudget slaveBudget);

    @Mapping(source = "masterAccount", target = "account")
    @Mapping(source = "masterCategory", target = "category")
    SlaveBudget masterToSlave(MasterBudget masterBudget);
}
