package org.kuenteco.backend.repository.master;

import org.kuenteco.backend.entity.extra.ExchangeRate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "masterTransactionManager")
public interface MasterExchangeRateRepository extends JpaRepository<ExchangeRate, Integer> {
    @Query(value = "SELECT update_exchange_rates()", nativeQuery = true)
    void getExchangeRates();
}
