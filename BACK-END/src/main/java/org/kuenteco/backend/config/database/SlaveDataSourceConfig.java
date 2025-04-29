package org.kuenteco.backend.config.database;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;
@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(basePackages = "org.kuenteco.backend.repository.slave", entityManagerFactoryRef = "slaveEntityManagerFactory", transactionManagerRef = "slaveTransactionManager")
public class SlaveDataSourceConfig {
    @Autowired
    private Environment environment;

    @Bean(name = "slaveDataSource")
    public DataSource dataSource() {
        DriverManagerDataSource slaveDataSource = new DriverManagerDataSource();
        slaveDataSource.setUrl(environment.getProperty("slave.datasource.url"));
        slaveDataSource.setUsername(environment.getProperty("slave.datasource.username"));
        slaveDataSource.setPassword(environment.getProperty("slave.datasource.password"));
        return slaveDataSource;
    }

    @Bean(name = "slaveEntityManagerFactory")
    public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(dataSource());
        em.setPackagesToScan("org.kuenteco.backend.entity");

        HibernateJpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);

        Map<String, Object> properties = new HashMap<>();
        // Configuración explicita del read-only
        properties.put("hibernate.connection.read_only", "true");
        em.setJpaPropertyMap(properties);

        return em;
    }

    @Bean(name = "slaveTransactionManager")
    public PlatformTransactionManager transactionManager() {
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(entityManagerFactory().getObject());
        return transactionManager;
    }
}
