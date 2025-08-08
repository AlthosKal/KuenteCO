package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.*;
import org.kuenteco.backend.enums.PaymentStatus;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "mercadopago_payment")
public class MercadoPagoPayment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "id_preapproval",
            nullable = false,
            foreignKey =
                    @ForeignKey(
                            name = "fk_preapproval",
                            foreignKeyDefinition =
                                    "FOREIGN KEY (id_preapproval) REFERENCES mercadopago_preapproval(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private MercadoPagoPreapproval preapproval;

    @Column(name = "payment_id", unique = true)
    private String paymentId; // ID del pago generado por MercadoPago

    @Column(name = "transaction_amount", precision = 10, scale = 2)
    private BigDecimal transactionAmount;

    @Column(name = "currency_id")
    private String currencyId;

    @Enumerated(EnumType.STRING)
    private PaymentStatus status;

    @Column(name = "status_detail")
    private String statusDetail;

    @Column(name = "payment_method_id")
    private String paymentMethodId;

    @Column(name = "payment_type_id")
    private String paymentTypeId;

    @Column(name = "date_created")
    private LocalDateTime dateCreated;

    @Column(name = "date_approved")
    private LocalDateTime dateApproved;

    @Column(name = "date_last_updated")
    private LocalDateTime dateLastUpdated;

    @Column(name = "authorization_code")
    private String authorizationCode;

    @Column(name = "external_reference")
    private String externalReference;

    @Column(name = "description")
    private String description;
}
