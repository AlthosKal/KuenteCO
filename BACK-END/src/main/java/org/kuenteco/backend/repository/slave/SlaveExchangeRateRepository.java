package org.kuenteco.backend.repository.slave;

import org.kuenteco.backend.entity.extra.ExchangeRate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveExchangeRateRepository extends JpaRepository<ExchangeRate, Integer> {
    Optional<ExchangeRate> findTopByBaseCurrencyAndTargetCurrencyOrderByLastUpdatedDesc(String baseCurrency, String targetCurrency);
}
