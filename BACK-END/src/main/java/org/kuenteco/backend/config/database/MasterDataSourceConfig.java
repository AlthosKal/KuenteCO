package org.kuenteco.backend.config.database;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
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
@EnableJpaRepositories(basePackages = "org.kuenteco.backend.repository.master", entityManagerFactoryRef = "masterEntityManagerFactory", transactionManagerRef = "masterTransactionManager")
public class MasterDataSourceConfig {
    @Autowired
    private Environment environment;

    @Primary
    @Bean(name = "masterDataSource")
    public DataSource dataSource() {
        DriverManagerDataSource masterDataSource = new DriverManagerDataSource();
        masterDataSource.setUrl(environment.getProperty("master.datasource.url"));
        masterDataSource.setUsername(environment.getProperty("master.datasource.username"));
        masterDataSource.setPassword(environment.getProperty("master.datasource.password"));
        return masterDataSource;
    }

    @Primary
    @Bean(name = "masterEntityManagerFactory")
    public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(dataSource());
        em.setPackagesToScan("org.kuenteco.backend.entity.master");

        HibernateJpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);

        Map<String, Object> properties = new HashMap<>();
        properties.put("hibernate.show-sql", environment.getProperty("master.jpa.properties.hibernate.show_sql"));

        em.setJpaPropertyMap(properties);

        return em;
    }

    @Primary
    @Bean(name = "masterTransactionManager")
    public PlatformTransactionManager transactionManager() {
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(entityManagerFactory().getObject());
        return transactionManager;
    }
}
