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
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Primary
@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(
        basePackages = "org.kuenteco.backend.repository.master",
        entityManagerFactoryRef = "masterEntityManagerFactory",
        transactionManagerRef = "masterTransactionManager")
public class MasterDataSourceConfig {
    private static final Logger log = LoggerFactory.getLogger(MasterDataSourceConfig.class);

    @Autowired private Environment environment;

    @Primary
    @Bean(name = "masterDataSource")
    public DataSource dataSource() {
        log.info("Configurando entity data source para la base de datos maestra");
        DriverManagerDataSource masterDataSource = new DriverManagerDataSource();
        masterDataSource.setUrl(environment.getProperty("spring.datasource.url"));
        masterDataSource.setUsername(environment.getProperty("spring.datasource.username"));
        masterDataSource.setPassword(environment.getProperty("spring.datasource.password"));
        return masterDataSource;
    }

    @Primary
    @Bean(name = "masterEntityManagerFactory")
    public LocalContainerEntityManagerFactoryBean entityManagerFactory(
            EntityManagerFactoryBuilder builder) {
        log.info("Configurando entity Manager Factory para la base de datos maestra");

        Map<String, Object> properties = new HashMap<>();
        properties.put(
                "hibernate.jdbc.lob.non_contextual_creation",
                environment.getProperty(
                        "spring.jpa.properties.hibernate.jdbc.lob.non_contextual_creation",
                        "true"));
        properties.put("hibernate.current_session_context_class", "thread");
        properties.put("hibernate.id.new_generator_mappings", "true");

        return builder.dataSource(dataSource())
                .packages("org.kuenteco.backend.entity")
                .persistenceUnit("master")
                .properties(properties)
                .build();
    }

    @Primary
    @Bean(name = "masterTransactionManager")
    public PlatformTransactionManager transactionManager(
            @Qualifier("masterEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory);
    }
}