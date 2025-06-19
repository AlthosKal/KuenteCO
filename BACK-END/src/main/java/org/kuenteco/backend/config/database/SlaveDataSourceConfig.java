package org.kuenteco.backend.config.database;

import java.util.HashMap;
import java.util.Map;
import javax.sql.DataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(
        basePackages = "org.kuenteco.backend.repository.slave",
        entityManagerFactoryRef = "slaveEntityManagerFactory",
        transactionManagerRef = "slaveTransactionManager")
public class SlaveDataSourceConfig {
    private static final Logger log = LoggerFactory.getLogger(MasterDataSourceConfig.class);
    @Autowired private Environment environment;

    @Bean(name = "slaveDataSource")
    public DataSource dataSource() {
        log.info("Configurando data source para la replica");
        DriverManagerDataSource slaveDataSource = new DriverManagerDataSource();
        slaveDataSource.setUrl(environment.getProperty("slave.datasource.url"));
        slaveDataSource.setUsername(environment.getProperty("slave.datasource.username"));
        slaveDataSource.setPassword(environment.getProperty("slave.datasource.password"));
        slaveDataSource.setDriverClassName(
                environment.getProperty("slave.datasource.driver-class-name"));
        return slaveDataSource;
    }

    @Bean(name = "slaveEntityManagerFactory")
    public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
        log.info("Configurando entity Manager Factory para la replica");
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(dataSource());
        em.setPackagesToScan("org.kuenteco.backend.entity");

        HibernateJpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        vendorAdapter.setGenerateDdl(false);
        em.setJpaVendorAdapter(vendorAdapter);

        Map<String, Object> properties = new HashMap<>();
        properties.put(
                "hibernate.show_sql",
                environment.getProperty("slave.jpa.properties.hibernate.show_sql", "false"));
        properties.put(
                "hibernate.format_sql",
                environment.getProperty("slave.jpa.properties.hibernate.format_sql", "false"));
        properties.put("hibernate.hbm2ddl.auto", "none"); // Forzamos a none para el esclavo

        // Configuración explícita para modo sólo lectura
        properties.put("hibernate.connection.read_only", "true");
        properties.put(
                "hibernate.connection.handling_mode",
                "DELAYED_ACQUISITION_AND_RELEASE_AFTER_TRANSACTION");
        properties.put("hibernate.query.read_only", "true");
        em.setJpaPropertyMap(properties);

        return em;
    }

    @Bean(name = "slaveTransactionManager")
    public PlatformTransactionManager transactionManager() {
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(entityManagerFactory().getObject());
        // Aseguramos que las transacciones son siempre de solo lectura
        transactionManager.setDefaultTimeout(10); // timeout en segundos
        transactionManager.setRollbackOnCommitFailure(true);
        return transactionManager;
    }
}
