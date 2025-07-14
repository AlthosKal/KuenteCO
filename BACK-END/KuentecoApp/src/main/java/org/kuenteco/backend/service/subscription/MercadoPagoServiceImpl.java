package org.kuenteco.backend.service.subscription;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import com.mercadopago.client.preapproval.PreApprovalAutoRecurringCreateRequest;
import com.mercadopago.client.preapproval.PreapprovalClient;
import com.mercadopago.client.preapproval.PreapprovalCreateRequest;
import com.mercadopago.exceptions.MPApiException;
import com.mercadopago.exceptions.MPException;
import com.mercadopago.resources.preapproval.Preapproval;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.subscription.SubscriptionPriceConfigDTO;
import org.kuenteco.backend.dto.subscription.request.CreateSubscriptionRequestDTO;
import org.kuenteco.backend.dto.subscription.response.CreateSubscriptionResponseDTO;
import org.kuenteco.backend.dto.subscription.response.SubscriptionResponseDTO;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.PreapprovalStatus;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.exception.exceptions.MercadoPagoException;
import org.kuenteco.backend.exception.exceptions.SubscriptionMercadoPagoException;
import org.kuenteco.backend.exception.exceptions.SubscriptionPriceException;
import org.kuenteco.backend.exception.exceptions.TransactionException;
import org.kuenteco.backend.mapper.subscription.MercadoPagoPreapprovalMapper;
import org.kuenteco.backend.repository.master.MasterMercadoPagoPreapprovalRepository;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveMercadoPagoPreapprovalRepository;
import org.kuenteco.backend.repository.slave.SlaveSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class MercadoPagoServiceImpl implements MercadoPagoService {
    private final MasterMercadoPagoPreapprovalRepository masterMercadoPagoPreapprovalRepository;
    private final SlaveMercadoPagoPreapprovalRepository slaveMercadoPagoPreapprovalRepository;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final SlaveSubscriptionRepository slaveSubscriptionRepository;
    private final MercadoPagoPreapprovalMapper preapprovalMapper;
    private final SlaveUserRepository slaveUserRepository;
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
    @Transactional
    public CreateSubscriptionResponseDTO createSubscription(
            CreateSubscriptionRequestDTO request, String userEmail) {
        AuthCredentials credentials = getCredentials();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new TransactionException("Endpoint solo disponible para usuarios");
        }

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

            // Validar suscripciones activas del usuario
            validateActiveSubscriptions(user, request.getSubscriptionType());

            // Obtener configuración de precios
            SubscriptionPriceConfigDTO priceConfig = getPriceConfig(request.getSubscriptionType());

            // Generar referencia externa única
            String externalReference =
                    generateExternalReference(user.getId(), request.getSubscriptionType());

            // Crear preapproval en MercadoPago
            Preapproval preapproval =
                    createMercadoPagoPreapproval(
                            priceConfig, externalReference, userEmail, request.getBackUrl());

            // Guardar en base de datos
            MercadoPagoPreapproval savedPreapproval =
                    saveMercadoPagoPreapproval(preapproval, user, priceConfig);

            // Actualizar o crear suscripción
            updateOrCreateSubscription(user, savedPreapproval, request.getSubscriptionType());

            log.info(
                    "Suscripción creada exitosamente para usuario: {}, preapproval ID: {}",
                    userEmail,
                    preapproval.getId());

            return preapprovalMapper.toCreateSubscriptionResponse(savedPreapproval);

        } catch (MPApiException e) {
            log.error("Error al crear preapproval en MercadoPago: {}", e.getMessage(), e);
            if (e.getApiResponse() != null) {
                log.error(
                        "Detalles del error de MercadoPago - Status: {}, Body: {}",
                        e.getApiResponse().getStatusCode(),
                        e.getApiResponse().getContent());
            }
            throw new MercadoPagoException(
                    "Error al crear suscripción en MercadoPago: " + e.getMessage());
        } catch (MPException e) {
            log.error("Error al crear preapproval en MercadoPago: {}", e.getMessage(), e);
            throw new MercadoPagoException(
                    "Error al crear suscripción en MercadoPago: " + e.getMessage());
        } catch (SubscriptionMercadoPagoException | TransactionException e) {
            // Re-lanzar excepciones de negocio sin modificar
            throw e;
        } catch (Exception e) {
            log.error("Error inesperado al crear suscripción: {}", e.getMessage(), e);
            throw new SubscriptionMercadoPagoException(
                    "Error al crear suscripción: " + e.getMessage());
        }
    }

    @Override
    public SubscriptionResponseDTO getSubscription(String preapprovalId, String userEmail) {
        AuthCredentials credentials = getCredentials();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new TransactionException("Endpoint solo disponible para usuarios");
        }

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

    @Override
    public SubscriptionResponseDTO getUserSubscriptions() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () ->
                                        new SubscriptionMercadoPagoException(
                                                "Usuario no encontrado"));

        Subscription subscription =
                slaveSubscriptionRepository
                        .getSubscriptionByUser(user)
                        .orElseThrow(
                                () ->
                                        new SubscriptionMercadoPagoException(
                                                "Subscripción no encontrada"));
        MercadoPagoPreapproval mercadoPagoPreapproval =
                slaveMercadoPagoPreapprovalRepository
                        .findByUser(user)
                        .orElseThrow(
                                () ->
                                        new SubscriptionMercadoPagoException(
                                                "Subscripción no encontrada"));
        return preapprovalMapper.toDTO(subscription, mercadoPagoPreapproval);
    }

    /** Valida si el usuario puede crear una nueva suscripción */
    private void validateActiveSubscriptions(User user, SubscriptionType newSubscriptionType) {
        // Buscar suscripciones activas del usuario
        List<Subscription> activeSubscriptions =
                slaveSubscriptionRepository.findByUserAndState(user, State.ACTIVE);

        if (!activeSubscriptions.isEmpty()) {
            Subscription activeSubscription = activeSubscriptions.get(0);

            // Si la suscripción activa es del mismo tipo, no permitir duplicados
            if (activeSubscription.getType() == newSubscriptionType) {
                throw new SubscriptionMercadoPagoException(
                        String.format(
                                "El usuario ya tiene una suscripción activa del tipo %s",
                                newSubscriptionType.name()));
            }

            // Si quiere cambiar de plan, marcar la suscripción actual como cancelada
            log.info(
                    "Usuario {} tiene suscripción activa tipo {}, cambiando a tipo {}",
                    user.getEmail(),
                    activeSubscription.getType(),
                    newSubscriptionType);

            activeSubscription.setState(State.CANCELLED);
            activeSubscription.setUpdatedAt(LocalDateTime.now());
            masterSubscriptionRepository.save(activeSubscription);

            // También cancelar el preapproval asociado si existe
            if (activeSubscription.getMercadoPagoPreapproval() != null) {
                MercadoPagoPreapproval activePreapproval =
                        activeSubscription.getMercadoPagoPreapproval();
                activePreapproval.setStatus(PreapprovalStatus.CANCELLED);
                activePreapproval.setLastModified(LocalDateTime.now());
                masterMercadoPagoPreapprovalRepository.save(activePreapproval);
            }
        }

        // Buscar suscripciones pendientes
        List<Subscription> pendingSubscriptions =
                slaveSubscriptionRepository.findByUserAndState(user, State.PENDING);

        if (!pendingSubscriptions.isEmpty()) {
            log.info(
                    "Usuario {} tiene {} suscripciones pendientes, cancelándolas",
                    user.getEmail(),
                    pendingSubscriptions.size());

            for (Subscription pendingSubscription : pendingSubscriptions) {
                pendingSubscription.setState(State.CANCELLED);
                pendingSubscription.setUpdatedAt(LocalDateTime.now());
                masterSubscriptionRepository.save(pendingSubscription);

                // Cancelar preapproval asociado
                if (pendingSubscription.getMercadoPagoPreapproval() != null) {
                    MercadoPagoPreapproval pendingPreapproval =
                            pendingSubscription.getMercadoPagoPreapproval();
                    pendingPreapproval.setStatus(PreapprovalStatus.CANCELLED);
                    pendingPreapproval.setLastModified(LocalDateTime.now());
                    masterMercadoPagoPreapprovalRepository.save(pendingPreapproval);
                }
            }
        }
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
                "SUB_%s_%s_%s_%d",
                userId.substring(0, Math.min(8, userId.length())),
                subscriptionType.name(),
                UUID.randomUUID().toString().substring(0, 8),
                System.currentTimeMillis());
    }

    private Preapproval createMercadoPagoPreapproval(
            SubscriptionPriceConfigDTO priceConfig,
            String externalReference,
            String userEmail,
            String backUrl)
            throws MPException, MPApiException {

        PreapprovalClient client = new PreapprovalClient();

        // Usar backUrl proporcionado o el por defecto
        String finalBackUrl =
                (backUrl != null && !backUrl.trim().isEmpty()) ? backUrl : defaultBackUrl;

        PreapprovalCreateRequest createRequest =
                PreapprovalCreateRequest.builder()
                        .reason(priceConfig.getDescription())
                        .externalReference(externalReference)
                        .payerEmail(userEmail)
                        .backUrl(finalBackUrl)
                        .autoRecurring(
                                PreApprovalAutoRecurringCreateRequest.builder()
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

    private void updateOrCreateSubscription(
            User user, MercadoPagoPreapproval preapproval, SubscriptionType subscriptionType) {

        // Crear nueva suscripción (las anteriores ya fueron canceladas en
        // validateActiveSubscriptions)
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

        log.info(
                "Nueva suscripción creada para usuario: {}, ID: {}, tipo: {}",
                user.getEmail(),
                subscription.getId(),
                subscriptionType);

        // Actualizar la referencia bidireccional
        preapproval.setSubscription(subscription);
        masterMercadoPagoPreapprovalRepository.save(preapproval);
    }
}
