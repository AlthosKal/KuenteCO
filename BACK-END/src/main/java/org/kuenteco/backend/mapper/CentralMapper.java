package org.kuenteco.backend.mapper;

import org.kuenteco.backend.mapper.dto.AccountDetailMapper;
import org.kuenteco.backend.mapper.dto.SubscriptionDetailMapper;
import org.kuenteco.backend.mapper.entity.*;
import org.kuenteco.backend.mapper.entity.extra.ExtraClassesMapper;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = { UserMapper.class, AccountMapper.class, BudgetMapper.class,
        CategoryMapper.class, TransactionMapper.class, SubscriptionMapper.class, InvestmentMapper.class,
        RoleMapper.class, NotificationMapper.class, DebtMapper.class, PaySubscriptionMapper.class,
        PaymentHistoryMapper.class, ExtraClassesMapper.class, SubscriptionDetailMapper.class,
        AccountDetailMapper.class })
public interface CentralMapper {
}
