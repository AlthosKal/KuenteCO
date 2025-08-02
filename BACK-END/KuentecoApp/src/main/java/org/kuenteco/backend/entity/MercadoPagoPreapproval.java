// Entidad para almacenar información de preapproval de MercadoPago
package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.*;
import org.kuenteco.backend.enums.PreapprovalStatus;

@Getter
@Setter
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "mercadopago_preapproval")
public class MercadoPagoPreapproval {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", nullable = false,
            foreignKey = @ForeignKey(name = "fk_user",
                    foreignKeyDefinition = "FOREIGN KEY (id_user) REFERENCES kuentecouser(id) ON UPDATE RESTRICT ON DELETE CASCADE"))
    private User user;

    @Column(name = "preapproval_id", unique = true)
    private String preapprovalId; // ID de preapproval generado por MercadoPago

    @Column(name = "external_reference")
    private String externalReference; // Referencia externa para identificar la suscripción

    @Column(name = "init_point")
    private String initPoint; // URL para completar el pago

    @Column(name = "payer_email")
    private String payerEmail;

    @Column(name = "auto_recurring_frequency")
    private Integer autoRecurringFrequency; // Frecuencia en días (30 para mensual)

    @Column(name = "auto_recurring_frequency_type")
    private String autoRecurringFrequencyType; // "days"

    @Column(name = "auto_recurring_transaction_amount", precision = 10, scale = 2)
    private BigDecimal autoRecurringTransactionAmount;

    @Column(name = "auto_recurring_currency_id")
    private String autoRecurringCurrencyId; // "COP"

    @Column(name = "back_url")
    private String backUrl; // URL de retorno después del pago

    @Enumerated(EnumType.STRING)
    private PreapprovalStatus status;

    @Column(name = "date_created")
    private LocalDateTime dateCreated;

    @Column(name = "last_modified")
    private LocalDateTime lastModified;

    @Column(name = "next_payment_date")
    private LocalDateTime nextPaymentDate;

    @Column(name = "payment_method_id")
    private String paymentMethodId; // Método de pago usado

    @Column(name = "card_last_four_digits")
    private String cardLastFourDigits;

    @Column(name = "card_brand")
    private String cardBrand;

    @Column(name = "reason")
    private String reason; // Descripción del plan de suscripción

    @OneToOne(mappedBy = "mercadoPagoPreapproval", cascade = CascadeType.ALL)
    private Subscription subscription;
}
