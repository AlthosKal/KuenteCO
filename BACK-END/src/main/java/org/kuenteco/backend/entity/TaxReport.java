package org.kuenteco.backend.entity;

import jakarta.persistence.*;

import java.sql.Timestamp;

@Entity
@Table(name = "tax_report")
public class TaxReport {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_account")
    private Account account;

    @Column(name = "tax_year")
    private Integer taxYear;

    @Column(name = "generated_date")
    private Timestamp generatedDate;

    @Column(name = "report_url")
    private String reportUrl;

    private String status;
}
