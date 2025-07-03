package org.kuenteco.backend.service.subscription;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.math.BigDecimal;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.api.WompiConfig;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.subscription.request.WompiTransactionRequestDTO;
import org.kuenteco.backend.dto.subscription.request.api.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.WompiTransactionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.api.SubscriptionPaymentResponseDTO;
import org.kuenteco.backend.entity.*;
import org.kuenteco.backend.entity.extra.DescriptionPaymentHistory;
import org.kuenteco.backend.entity.extra.PayMethodInfo;
import org.kuenteco.backend.enums.*;
import org.kuenteco.backend.exception.exceptions.PaymentProcessingException;
import org.kuenteco.backend.exception.exceptions.TokenizationException;
import org.kuenteco.backend.mapper.subscription.SubscriptionMapper;
import org.kuenteco.backend.mapper.subscription.WompiMapper;
import org.kuenteco.backend.repository.master.MasterPaySubscriptionRepository;
import org.kuenteco.backend.repository.master.MasterPaymentHistoryRepository;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveUserPaymentTokenRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.wompi.PaymentTokenService;
import org.kuenteco.backend.service.wompi.WompiService;
import org.springframework.stereotype.Service;

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
    private final SlaveUserRepository slaveUserRepository;
    private final SubscriptionMapper subscriptionMapper;
    private final WompiMapper wompiMapper;
    private final SlaveUserPaymentTokenRepository slaveUserPaymentTokenRepository;
    private final WompiConfig wompiConfig;

    // Precios de suscripciones
    private static final Map<SubscriptionType, BigDecimal> SUBSCRIPTION_PRICES =
            Map.of(
                    SubscriptionType.BASIC, new BigDecimal("7"),
                    SubscriptionType.STANDARD, new BigDecimal("13"),
                    SubscriptionType.PREMIUM, new BigDecimal("20"));

    @Override
    public SubscriptionPaymentResponseDTO createSubscriptionPayment(
            CreateSubscriptionRequestDTO request) throws NoSuchAlgorithmException {
        // Validar y obtener token de pago
        UserPaymentToken paymentToken = getOrCreatePaymentToken(request);

        // Crear suscripción
        Subscription subscription = createSubscription(request.getSubscriptionType());

        // Procesar pago
        PaySubscription paySubscription = processPayment(subscription, paymentToken, request);

        // Crear historial de pago
        createPaymentHistory(paySubscription, request.getSubscriptionType());

        log.info(
                "Proceso de pago completado exitosamente para suscripción ID: {}",
                subscription.getId());

        return subscriptionMapper.toDTO(subscription, paySubscription, paymentToken);
    }

    @Override
    public SubscriptionPaymentResponseDTO getSubscriptionStatus(Integer subscriptionId) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () ->
                                        new PaymentProcessingException(
                                                "Usuario no encontrado con el email: " + email));
        Subscription subscription =
                slaveSubscriptionRepository
                        .findById(subscriptionId)
                        .orElseThrow(
                                () -> new PaymentProcessingException("Suscripción no encontrada"));

        if (!subscription.getUser().getId().equals(user.getId())) {
            throw new PaymentProcessingException("No tiene permisos para ver esta suscripción");
        }

        // Buscar pago asociado
        PaySubscription paySubscription =
                masterPaySubscriptionRepository.findBySubscription(subscription);

        if (paySubscription == null) {
            throw new PaymentProcessingException("Información de pago no encontrada");
        }

        return subscriptionMapper.toDTOWithToken(subscription, paySubscription);
    }

    private UserPaymentToken getOrCreatePaymentToken(CreateSubscriptionRequestDTO request) {
        if (request.getPaymentTokenId() != null) {
            // Usar token existente
            return getActiveTokenById(request.getPaymentTokenId());
        } else if (request.getCardInfo() != null) {
            // Tokenizar nueva tarjeta
            paymentTokenService.tokenizeAndSaveCard(request.getCardInfo());
            // Obtener el token recién creado
            return paymentTokenService.getUserActiveTokens().stream()
                    .findFirst()
                    .map(tokenResponse -> getActiveTokenById(tokenResponse.getTokenId()))
                    .orElseThrow(
                            () -> new PaymentProcessingException("Error al obtener token de pago"));
        } else {
            throw new PaymentProcessingException(
                    "Debe proporcionar un token de pago o información de tarjeta");
        }
    }

    private Subscription createSubscription(SubscriptionType type) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () ->
                                        new PaymentProcessingException(
                                                "Error al obtener usuario de pago con el email: "
                                                        + email));
        Subscription subscription =
                Subscription.builder()
                        .user(user)
                        .type(type)
                        .startDate(LocalDateTime.now())
                        .expirationDate(LocalDateTime.now().plusMonths(1))
                        .state(State.PENDING)
                        .build();

        return masterSubscriptionRepository.save(subscription);
    }

    private PaySubscription processPayment(
            Subscription subscription,
            UserPaymentToken paymentToken,
            CreateSubscriptionRequestDTO subscriptionRequest)
            throws NoSuchAlgorithmException {
        BigDecimal amount = SUBSCRIPTION_PRICES.get(subscription.getType());
        String reference = generatePaymentReference(subscription);

        // Crear transacción en Wompi
        WompiTransactionRequestDTO transactionRequest =
                buildWompiTransactionRequest(
                        subscription, paymentToken, amount, reference, subscriptionRequest);

        WompiTransactionResponseDTO wompiResponse =
                wompiService.createTransaction(transactionRequest);

        // Crear registro de pago
        PaySubscription paySubscription =
                PaySubscription.builder()
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
    }

    private WompiTransactionRequestDTO buildWompiTransactionRequest(
            Subscription subscription,
            UserPaymentToken paymentToken,
            BigDecimal amount,
            String reference,
            CreateSubscriptionRequestDTO subscriptionRequest)
            throws NoSuchAlgorithmException {

        String signature =
                wompiService.generateSignature(
                        reference, amount, CurrencyType.USD, wompiConfig.getIntegritySecret());

        return wompiMapper.toWompiTransactionRequest(
                subscription,
                paymentToken,
                amount,
                reference,
                signature,
                CurrencyType.USD,
                subscriptionRequest);
    }

    private PayMethodInfo buildPayMethodInfo(UserPaymentToken paymentToken) {
        return new PayMethodInfo(
                PaymentMethod.CARD,
                paymentToken.getCardLastFour(),
                paymentToken.getUser().getEmail());
    }

    private void createPaymentHistory(
            PaySubscription paySubscription, SubscriptionType subscriptionType) {
        DescriptionPaymentHistory historyDetails =
                DescriptionPaymentHistory.builder()
                        .type(subscriptionType)
                        .paymentMethod(paySubscription.getPayMethod().getMethod())
                        .amount(paySubscription.getAmount())
                        .date(LocalDateTime.now())
                        .build();

        PaymentHistory history =
                PaymentHistory.builder()
                        .paySubscription(paySubscription)
                        .details(historyDetails)
                        .build();

        masterPaymentHistoryRepository.save(history);
    }

    private void updateSubscriptionStatus(Subscription subscription, PaymentStatus paymentStatus) {
        if (paymentStatus == PaymentStatus.APPROVED) {
            subscription.setState(State.ACTIVE);
        } else if (paymentStatus == PaymentStatus.DECLINED
                || paymentStatus == PaymentStatus.ERROR) {
            subscription.setState(State.INACTIVE);
        }
        // PENDING mantiene el estado PENDING

        masterSubscriptionRepository.save(subscription);
    }

    public static PaymentStatus mapWompiStatusToPaymentStatus(String wompiStatus) {
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

    private UserPaymentToken getActiveTokenById(Integer tokenId) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () ->
                                        new TokenizationException(
                                                "Usuario no encontrado con el email " + email));
        return slaveUserPaymentTokenRepository
                .findByIdAndUserAndIsActiveTrue(tokenId, user)
                .orElseThrow(() -> new TokenizationException("Token no encontrado o inactivo"));
    }
}
