package org.kuenteco.backend.config.database;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

@Primary
@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(basePackages = "org.kuenteco.backend.repository.master", entityManagerFactoryRef = "masterEntityManagerFactory", transactionManagerRef = "masterTransactionManager")
public class MasterDataSourceConfig {
    @Autowired
    private Environment environment;
    private static final Logger log = LoggerFactory.getLogger(MasterDataSourceConfig.class);

    @Primary
    @Bean(name = "masterDataSource")
    public DataSource dataSource() {
        log.info("Configurando entity Manager Factory para la base de datos maestra");
        DriverManagerDataSource masterDataSource = new DriverManagerDataSource();
        masterDataSource.setUrl(environment.getProperty("spring.datasource.url"));
        masterDataSource.setUsername(environment.getProperty("spring.datasource.username"));
        masterDataSource.setPassword(environment.getProperty("spring.datasource.password"));
        masterDataSource.setDriverClassName(environment.getProperty("spring.datasource.driver-class-name"));
        return masterDataSource;
    }

    @Primary
    @Bean(name = "masterEntityManagerFactory")
    public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
        log.info("Configurando entity Manager Factory para la base de datos maestra");
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(dataSource());
        em.setPackagesToScan("org.kuenteco.backend.entity");

        HibernateJpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        vendorAdapter.setGenerateDdl(true); // Importante para permitir a Hibernate generar DDL
        em.setJpaVendorAdapter(vendorAdapter);

        Map<String, Object> properties = new HashMap<>();
        properties.put("hibernate.show_sql", environment.getProperty("spring.jpa.properties.hibernate.show_sql", "false"));
        properties.put("hibernate.format_sql", environment.getProperty("spring.jpa.properties.hibernate.format_sql", "false"));
        properties.put("hibernate.hbm2ddl.auto", environment.getProperty("spring.jpa.hibernate.ddl-auto", "validate"));
        properties.put("hibernate.dialect", environment.getProperty("spring.jpa.properties.hibernate.dialect", "org.hibernate.dialect.PostgreSQLDialect"));
        properties.put("hibernate.jdbc.lob.non_contextual_creation", environment.getProperty("spring.jpa.properties.hibernate.jdbc.lob.non_contextual_creation", "true"));
        properties.put("hibernate.current_session_context_class", "thread");
        properties.put("hibernate.id.new_generator_mappings", "true");

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
