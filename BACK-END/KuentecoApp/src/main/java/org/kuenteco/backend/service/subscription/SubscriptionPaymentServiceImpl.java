package org.kuenteco.backend.service.subscription;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.subscription.request.WompiTransactionRequestDTO;
import org.kuenteco.backend.dto.subscription.request.api.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.WompiTransactionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.api.SubscriptionPaymentResponseDTO;
import org.kuenteco.backend.entity.*;
import org.kuenteco.backend.entity.extra.DescriptionPaymentHistory;
import org.kuenteco.backend.entity.extra.PayMethodInfo;
import org.kuenteco.backend.enums.*;
import org.kuenteco.backend.exception.exceptions.PaymentProcessingException;
import org.kuenteco.backend.repository.master.MasterPaySubscriptionRepository;
import org.kuenteco.backend.repository.master.MasterPaymentHistoryRepository;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveSubscriptionRepository;
import org.kuenteco.backend.service.wompi.PaymentTokenService;
import org.kuenteco.backend.service.wompi.WompiService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class SubscriptionPaymentServiceImpl implements SubscriptionPaymentService {
    private final WompiService wompiService;
    private final PaymentTokenService paymentTokenService;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final MasterPaySubscriptionRepository masterPaySubscriptionRepository;
    private final MasterPaymentHistoryRepository masterPaymentHistoryRepository;
    private final SlaveSubscriptionRepository slaveSubscriptionRepository;

    @Value("${wompi.integrity-secret}")
    private String integritySecret;

    @Value("${app.subscription.redirect-url}")
    private String redirectUrl;

    // Precios de suscripciones
    private static final Map<SubscriptionType, BigDecimal> SUBSCRIPTION_PRICES = Map.of(
            SubscriptionType.BASIC, new BigDecimal("29900"),
            SubscriptionType.STANDARD, new BigDecimal("49900"),
            SubscriptionType.PREMIUM, new BigDecimal("79900")
    );

    @Override
    public SubscriptionPaymentResponseDTO createSubscriptionPayment(User user, CreateSubscriptionRequestDTO request) {
        try {
            log.info("Iniciando proceso de pago de suscripción para usuario: {}", user.getEmail());

            // Validar y obtener token de pago
            UserPaymentToken paymentToken = getOrCreatePaymentToken(user, request);

            // Crear suscripción
            Subscription subscription = createSubscription(user, request.getSubscriptionType());

            // Procesar pago
            PaySubscription paySubscription = processPayment(subscription, paymentToken);

            // Crear historial de pago
            createPaymentHistory(paySubscription, request.getSubscriptionType());

            log.info("Proceso de pago completado exitosamente para suscripción ID: {}", subscription.getId());

            return buildSubscriptionPaymentResponse(subscription, paySubscription, paymentToken);

        } catch (Exception e) {
            log.error("Error al procesar pago de suscripción para usuario {}: {}", user.getEmail(), e.getMessage(), e);
            throw new PaymentProcessingException("Error al procesar pago de suscripción: " + e.getMessage(), e);
        }
    }

    private UserPaymentToken getOrCreatePaymentToken(User user, CreateSubscriptionRequestDTO request) {
        if (request.getPaymentTokenId() != null) {
            // Usar token existente
            return paymentTokenService.getActiveTokenById(request.getPaymentTokenId(), user);
        } else if (request.getCardInfo() != null) {
            // Tokenizar nueva tarjeta
            paymentTokenService.tokenizeAndSaveCard(user, request.getCardInfo());
            // Obtener el token recién creado
            return paymentTokenService.getUserActiveTokens(user).stream()
                    .findFirst()
                    .map(tokenResponse -> paymentTokenService.getActiveTokenById(tokenResponse.getTokenId(), user))
                    .orElseThrow(() -> new PaymentProcessingException("Error al obtener token de pago"));
        } else {
            throw new PaymentProcessingException("Debe proporcionar un token de pago o información de tarjeta");
        }
    }

    private Subscription createSubscription(User user, SubscriptionType type) {
        Subscription subscription = Subscription.builder()
                .user(user)
                .type(type)
                .startDate(LocalDateTime.now())
                .expirationDate(LocalDateTime.now().plusMonths(1))
                .state(State.PENDING)
                .build();

        return masterSubscriptionRepository.save(subscription);
    }

    private PaySubscription processPayment(Subscription subscription, UserPaymentToken paymentToken) {
        try {
            BigDecimal amount = SUBSCRIPTION_PRICES.get(subscription.getType());
            String reference = generatePaymentReference(subscription);

            // Crear transacción en Wompi
            WompiTransactionRequestDTO transactionRequest = buildWompiTransactionRequest(
                    subscription, paymentToken, amount, reference);

            WompiTransactionResponseDTO wompiResponse = wompiService.createTransaction(transactionRequest);

            // Crear registro de pago
            PaySubscription paySubscription = PaySubscription.builder()
                    .subscription(subscription)
                    .transactionId(wompiResponse.getData().getId())
                    .amount(amount)
                    .payDate(LocalDateTime.now())
                    .status(mapWompiStatusToPaymentStatus(wompiResponse.getData().getStatus()))
                    .payMethod(buildPayMethodInfo(paymentToken))
                    .build();

            paySubscription = masterPaySubscriptionRepository.save(paySubscription);

            // Actualizar estado de suscripción según el resultado del pago
            updateSubscriptionStatus(subscription, paySubscription.getStatus());

            return paySubscription;

        } catch (Exception e) {
            log.error("Error al procesar pago: {}", e.getMessage(), e);
            throw new PaymentProcessingException("Error al procesar pago", e);
        }
    }

    private WompiTransactionRequestDTO buildWompiTransactionRequest(
            Subscription subscription, UserPaymentToken paymentToken, BigDecimal amount, String reference) {

        String signature = wompiService.generateSignature(reference, amount, "COP", integritySecret);
        long amountInCents = amount.multiply(BigDecimal.valueOf(100)).longValue();

        return WompiTransactionRequestDTO.builder()
                .amountInCents(amountInCents)
                .currency(CurrencyType.COP)
                .signature(signature)
                .customerEmail(subscription.getUser().getEmail())
                .reference(reference)
                .paymentMethod(WompiTransactionRequestDTO.paymentMethod.builder()
                        .type("CARD")
                        .token(paymentToken.getWompiToken())
                        .installments(1)
                        .build())
                .redirectUrl(redirectUrl)
                .shippingAddress(WompiTransactionRequestDTO.shippingAddress.builder()
                        .addressLine1("Dirección por defecto")
                        .country("CO")
                        .region("Antioquia")
                        .city("Envigado")
                        .name(subscription.getUser().getUsername())
                        .phoneNumber("0000000000")
                        .build())
                .customerData(WompiTransactionRequestDTO.customerData.builder()
                        .phoneNumber("0000000000")
                        .fullName(subscription.getUser().getUsername())
                        .build())
                .build();
    }

    private PayMethodInfo buildPayMethodInfo(UserPaymentToken paymentToken) {
        return new PayMethodInfo(
                PaymentMethod.CARD,
                paymentToken.getCardLastFour(),
                paymentToken.getUser().getEmail()
        );
    }

    private void createPaymentHistory(PaySubscription paySubscription, SubscriptionType subscriptionType) {
        DescriptionPaymentHistory historyDetails = new DescriptionPaymentHistory(
                subscriptionType.name(),
                "CARD",
                paySubscription.getAmount(),
                paySubscription.getPayDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        );

        PaymentHistory history = PaymentHistory.builder()
                .paySubscription(paySubscription)
                .details(historyDetails)
                .build();

        masterPaymentHistoryRepository.save(history);
    }

    private void updateSubscriptionStatus(Subscription subscription, PaymentStatus paymentStatus) {
        if (paymentStatus == PaymentStatus.APPROVED) {
            subscription.setState(State.ACTIVE);
        } else if (paymentStatus == PaymentStatus.DECLINED || paymentStatus == PaymentStatus.ERROR) {
            subscription.setState(State.INACTIVE);
        }
        // PENDING mantiene el estado PENDING

        masterSubscriptionRepository.save(subscription);
    }

    private PaymentStatus mapWompiStatusToPaymentStatus(String wompiStatus) {
        return switch (wompiStatus.toUpperCase()) {
            case "APPROVED" -> PaymentStatus.APPROVED;
            case "DECLINED" -> PaymentStatus.DECLINED;
            case "VOIDED" -> PaymentStatus.VOIDED;
            case "ERROR" -> PaymentStatus.ERROR;
            default -> PaymentStatus.PENDING;
        };
    }

    private String generatePaymentReference(Subscription subscription) {
        return "SUB-" + subscription.getId() + "-" + UUID.randomUUID().toString().substring(0, 8);
    }

    private SubscriptionPaymentResponseDTO buildSubscriptionPaymentResponse(
            Subscription subscription, PaySubscription paySubscription, UserPaymentToken paymentToken) {
        return SubscriptionPaymentResponseDTO.builder()
                .subscriptionId(subscription.getId())
                .subscriptionType(subscription.getType())
                .amount(paySubscription.getAmount())
                .paymentStatus(paySubscription.getStatus().name())
                .transactionId(paySubscription.getTransactionId())
                .paymentDate(paySubscription.getPayDate())
                .cardLastFour(paymentToken.getCardLastFour())
                .expirationDate(subscription.getExpirationDate())
                .build();
    }

    @Override
    public SubscriptionPaymentResponseDTO getSubscriptionStatus(Integer subscriptionId, User user) {
        Subscription subscription = slaveSubscriptionRepository.findById(subscriptionId)
                .orElseThrow(() -> new PaymentProcessingException("Suscripción no encontrada"));

        if (!subscription.getUser().getId().equals(user.getId())) {
            throw new PaymentProcessingException("No tiene permisos para ver esta suscripción");
        }

        // Buscar pago asociado
        PaySubscription paySubscription = masterPaySubscriptionRepository
                .findBySubscription(subscription);

        if (paySubscription == null) {
            throw new PaymentProcessingException("Información de pago no encontrada");
        }

        return buildSubscriptionPaymentResponse(subscription, paySubscription, null);
    }
}
