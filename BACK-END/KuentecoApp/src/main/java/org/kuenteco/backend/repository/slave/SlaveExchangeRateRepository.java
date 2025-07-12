package org.kuenteco.backend.repository.slave;

import java.util.List;
import java.util.Optional;
import org.kuenteco.backend.entity.extra.ExchangeRate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveExchangeRateRepository extends JpaRepository<ExchangeRate, Integer> {
    Optional<ExchangeRate> findTopByBaseCurrencyAndTargetCurrencyOrderByLastUpdatedDesc(
            String baseCurrency, String targetCurrency);
}
