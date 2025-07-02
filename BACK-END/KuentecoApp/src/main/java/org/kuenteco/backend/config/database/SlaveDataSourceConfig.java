package org.kuenteco.backend.config.database;

import jakarta.persistence.EntityManagerFactory;
import java.util.HashMap;
import java.util.Map;
import javax.sql.DataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.orm.jpa.EntityManagerFactoryBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(
        basePackages = "org.kuenteco.backend.repository.slave",
        entityManagerFactoryRef = "slaveEntityManagerFactory",
        transactionManagerRef = "slaveTransactionManager")
public class SlaveDataSourceConfig {
    private static final Logger log = LoggerFactory.getLogger(SlaveDataSourceConfig.class);

    @Autowired private Environment environment;

    @Bean(name = "slaveDataSource")
    public DataSource dataSource() {
        log.info("Configurando data source para la replica");
        DriverManagerDataSource slaveDataSource = new DriverManagerDataSource();
        slaveDataSource.setUrl(environment.getProperty("slave.datasource.url"));
        slaveDataSource.setUsername(environment.getProperty("slave.datasource.username"));
        slaveDataSource.setPassword(environment.getProperty("slave.datasource.password"));
        return slaveDataSource;
    }

    @Bean(name = "slaveEntityManagerFactory")
    public LocalContainerEntityManagerFactoryBean entityManagerFactory(
            EntityManagerFactoryBuilder builder) {
        log.info("Configurando entity Manager Factory para la replica");

        Map<String, Object> properties = new HashMap<>();
        properties.put("hibernate.hbm2ddl.auto", "none"); // Forzamos a none para el esclavo

        // Configuración explícita para modo sólo lectura
        properties.put("hibernate.connection.read_only", "true");
        properties.put(
                "hibernate.connection.handling_mode",
                "DELAYED_ACQUISITION_AND_RELEASE_AFTER_TRANSACTION");
        properties.put("hibernate.query.read_only", "true");

        return builder.dataSource(dataSource())
                .packages("org.kuenteco.backend.entity")
                .persistenceUnit("slave")
                .properties(properties)
                .build();
    }

    @Bean(name = "slaveTransactionManager")
    public PlatformTransactionManager transactionManager(
            @Qualifier("slaveEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
        JpaTransactionManager transactionManager = new JpaTransactionManager(entityManagerFactory);
        // Aseguramos que las transacciones son siempre de solo lectura
        transactionManager.setDefaultTimeout(10); // timeout en segundos
        transactionManager.setRollbackOnCommitFailure(true);
        return transactionManager;
    }
}