package org.kuenteco.backend.service.subscription.mercado_pago;

import com.mercadopago.MercadoPagoConfig;
import com.mercadopago.client.preapproval.PreApprovalAutoRecurringCreateRequest;
import com.mercadopago.client.preapproval.PreapprovalClient;
import com.mercadopago.client.preapproval.PreapprovalCreateRequest;
import com.mercadopago.exceptions.MPApiException;
import com.mercadopago.exceptions.MPException;
import com.mercadopago.net.MPResource;
import com.mercadopago.resources.preapproval.Preapproval;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.subscription.mercado_pago.SubscriptionPriceConfigDTO;
import org.kuenteco.backend.dto.subscription.mercado_pago.request.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.mercado_pago.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.mercado_pago.response.SubscriptionResponseDTO;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.PreapprovalStatus;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.exception.exceptions.MercadoPagoException;
import org.kuenteco.backend.exception.exceptions.SubscriptionMercadoPagoException;
import org.kuenteco.backend.exception.exceptions.SubscriptionPriceException;
import org.kuenteco.backend.mapper.subscription.mercado_pago.MercadoPagoPreapprovalMapper;
import org.kuenteco.backend.repository.master.MasterMercadoPagoPreapprovalRepository;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveMercadoPagoPreapprovalRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class MercadoPagoServiceImpl implements MercadoPagoService {
    private final MasterMercadoPagoPreapprovalRepository masterMercadoPagoPreapprovalRepository;
    private final SlaveMercadoPagoPreapprovalRepository slaveMercadoPagoPreapprovalRepository;
    private final MercadoPagoPreapprovalMapper preapprovalMapper;
    private final SlaveUserRepository slaveUserRepository;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final String defaultBackUrl = "https://github.com/AlthosKal/KuenteCO";

    // Configuración de precios por tipo de suscripción
    private final Map<SubscriptionType, SubscriptionPriceConfigDTO> priceConfigs =
            Map.of(
                    SubscriptionType.BASIC,
                            SubscriptionPriceConfigDTO.builder()
                                    .type(SubscriptionType.BASIC)
                                    .monthlyPrice(new BigDecimal("19900"))
                                    .description("Plan Básico - KuenteCo")
                                    .currencyId("COP")
                                    .build(),
                    SubscriptionType.STANDARD,
                            SubscriptionPriceConfigDTO.builder()
                                    .type(SubscriptionType.STANDARD)
                                    .monthlyPrice(new BigDecimal("39900"))
                                    .description("Plan Estándar - KuenteCo")
                                    .currencyId("COP")
                                    .build(),
                    SubscriptionType.PREMIUM,
                            SubscriptionPriceConfigDTO.builder()
                                    .type(SubscriptionType.PREMIUM)
                                    .monthlyPrice(new BigDecimal("59900"))
                                    .description("Plan Premium - KuenteCo")
                                    .currencyId("COP")
                                    .build());

    @Override
    public CreateSubscriptionResponseDTO createSubscription(
            CreateSubscriptionRequestDTO request, String userEmail) {
        try {
            log.info("Iniciando creación de suscripción para usuario: {}", userEmail);

            // Validar que el usuario existe
            User user =
                    slaveUserRepository
                            .findByEmail(userEmail)
                            .orElseThrow(
                                    () ->
                                            new SubscriptionMercadoPagoException(
                                                    "Usuario no encontrado"));

            // Validar que no tenga una suscripción activa hasActiveSubscription
            if (slaveMercadoPagoPreapprovalRepository.existsByUserAndSubscriptionState(user, State.ACTIVE)) {
                throw new SubscriptionMercadoPagoException(
                        "El usuario ya tiene una suscripción activa");
            }

            // Obtener configuración de precios
            SubscriptionPriceConfigDTO priceConfig = getPriceConfig(request.getSubscriptionType());

            // Generar referencia externa única
            String externalReference =
                    generateExternalReference(user.getId(), request.getSubscriptionType());

            // Crear preapproval en MercadoPago
            Preapproval preapproval =
                    createMercadoPagoPreapproval(priceConfig, externalReference, userEmail);

            // Guardar en base de datos
            MercadoPagoPreapproval savedPreapproval =
                    saveMercadoPagoPreapproval(preapproval, user, priceConfig);

            // Crear suscripción asociada
                    createSubscription(user, savedPreapproval, request.getSubscriptionType());

            log.info(
                    "Suscripción creada exitosamente para usuario: {}, preapproval ID: {}",
                    userEmail,
                    preapproval.getId());

            return preapprovalMapper.toCreateSubscriptionResponse(savedPreapproval);

        } catch (MPApiException e) {
            log.error("Error al crear preapproval en MercadoPago: {}", e.getMessage(), e);
            if (e.getApiResponse() != null) {
                log.error("Detalles del error de MercadoPago - Status: {}, Body: {}",
                        e.getApiResponse().getStatusCode(),
                        e.getApiResponse().getContent());
            }
            throw new MercadoPagoException(
                    "Error al crear suscripción en MercadoPago: " + e.getMessage());
        } catch (MPException e) {
            log.error("Error al crear preapproval en MercadoPago: {}", e.getMessage(), e);
            throw new MercadoPagoException(
                    "Error al crear suscripción en MercadoPago: " + e.getMessage());
        } catch (Exception e) {
            log.error("Error inesperado al crear suscripción: {}", e.getMessage(), e);
            throw new SubscriptionMercadoPagoException(
                    "Error al crear suscripción: " + e.getMessage());
        }

    }

    @Override
    public SubscriptionResponseDTO getSubscription(String preapprovalId, String userEmail) {
        log.info(
                "Obteniendo suscripción para usuario: {}, preapproval ID: {}",
                userEmail,
                preapprovalId);

        User user =
                slaveUserRepository
                        .findByEmail(userEmail)
                        .orElseThrow(
                                () ->
                                        new SubscriptionMercadoPagoException(
                                                "Usuario no encontrado"));

        MercadoPagoPreapproval preapproval =
                slaveMercadoPagoPreapprovalRepository
                        .findByPreapprovalId(preapprovalId)
                        .orElseThrow(
                                () ->
                                        new SubscriptionMercadoPagoException(
                                                "Suscripción no encontrada"));

        if (!preapproval.getUser().getId().equals(user.getId())) {
            throw new SubscriptionMercadoPagoException(
                    "No tiene permisos para acceder a esta suscripción");
        }

        return preapprovalMapper.toSubscriptionResponse(preapproval);
    }

    private SubscriptionPriceConfigDTO getPriceConfig(SubscriptionType subscriptionType) {
        SubscriptionPriceConfigDTO config = priceConfigs.get(subscriptionType);
        if (config == null) {
            throw new SubscriptionPriceException(
                    "Configuración de precio no encontrada para: " + subscriptionType);
        }
        return config;
    }

    private String generateExternalReference(String userId, SubscriptionType subscriptionType) {
        return String.format(
                "SUB_%s_%s_%s",
                userId.substring(0, 8),
                subscriptionType.name(),
                UUID.randomUUID().toString().substring(0, 8));
    }

    private Preapproval createMercadoPagoPreapproval(
            SubscriptionPriceConfigDTO priceConfig, String externalReference, String userEmail)
            throws MPException, MPApiException {

        PreapprovalClient client = new PreapprovalClient();

        PreapprovalCreateRequest createRequest = PreapprovalCreateRequest.builder()
                .reason(priceConfig.getDescription())
                .externalReference(externalReference)
                .payerEmail(userEmail)
                .backUrl(defaultBackUrl) // AQUÍ va el back_url, obligatorio
                .autoRecurring(PreApprovalAutoRecurringCreateRequest.builder()
                        .frequency(30)
                        .frequencyType("days")
                        .transactionAmount(priceConfig.getMonthlyPrice())
                        .currencyId(priceConfig.getCurrencyId())
                        .build())
                .build();

        return client.create(createRequest);
    }


    private MercadoPagoPreapproval saveMercadoPagoPreapproval(
            Preapproval preapproval, User user, SubscriptionPriceConfigDTO priceConfig) {
        MercadoPagoPreapproval entity =
                MercadoPagoPreapproval.builder()
                        .user(user)
                        .preapprovalId(preapproval.getId())
                        .externalReference(preapproval.getExternalReference())
                        .initPoint(preapproval.getInitPoint())
                        .payerEmail(preapproval.getPayerEmail())
                        .autoRecurringFrequency(30)
                        .autoRecurringFrequencyType("days")
                        .autoRecurringTransactionAmount(priceConfig.getMonthlyPrice())
                        .autoRecurringCurrencyId(priceConfig.getCurrencyId())
                        .backUrl(preapproval.getBackUrl())
                        .status(PreapprovalStatus.PENDING)
                        .dateCreated(LocalDateTime.now())
                        .lastModified(LocalDateTime.now())
                        .nextPaymentDate(LocalDateTime.now().plusDays(30))
                        .reason(priceConfig.getDescription())
                        .build();

        return masterMercadoPagoPreapprovalRepository.save(entity);
    }

    private void createSubscription(
            User user, MercadoPagoPreapproval preapproval, SubscriptionType subscriptionType) {
        Subscription subscription =
                Subscription.builder()
                        .user(user)
                        .type(subscriptionType)
                        .startDate(LocalDateTime.now())
                        .expirationDate(LocalDateTime.now().plusDays(30))
                        .state(State.PENDING)
                        .mercadoPagoPreapproval(preapproval)
                        .isAutoRenewable(true)
                        .createdAt(LocalDateTime.now())
                        .updatedAt(LocalDateTime.now())
                        .build();

        subscription = masterSubscriptionRepository.save(subscription);

        // Actualizar la referencia bidireccional
        preapproval.setSubscription(subscription);
        masterMercadoPagoPreapprovalRepository.save(preapproval);

    }
}
