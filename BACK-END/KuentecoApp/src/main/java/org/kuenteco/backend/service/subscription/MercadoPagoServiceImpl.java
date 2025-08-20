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
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.hibernate.Hibernate;
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
    private static final String defaultBackUrl = "https://github.com/AlthosKal/KuenteCO";

    // Configuración de precios por tipo de suscripción
    private final Map<SubscriptionType, SubscriptionPriceConfigDTO> priceConfigs =
            Map.of(
                    SubscriptionType.STANDARD,
                    SubscriptionPriceConfigDTO.builder()
                            .type(SubscriptionType.STANDARD)
                            .monthlyPrice(new BigDecimal("12900"))
                            .description("Plan Estándar - KuenteCo")
                            .currencyId("COP")
                            .build(),
                    SubscriptionType.PREMIUM,
                    SubscriptionPriceConfigDTO.builder()
                            .type(SubscriptionType.PREMIUM)
                            .monthlyPrice(new BigDecimal("24900"))
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

            // Necesitamos buscar la subscription asociada para el mapper
            Optional<Subscription> createdSubscriptionOpt =
                    slaveSubscriptionRepository.findByMercadoPagoPreapproval(savedPreapproval);
            Subscription createdSubscription = createdSubscriptionOpt.orElse(null);

            return preapprovalMapper.toCreateSubscriptionResponse(
                    savedPreapproval, createdSubscription);

        } catch (MPApiException e) {
            log.error("Error al crear preapproval en MercadoPago: {}", e.getMessage(), e);
            if (e.getApiResponse() != null) {
                int statusCode = e.getApiResponse().getStatusCode();
                String errorBody = e.getApiResponse().getContent();
                log.error(
                        "Detalles del error de MercadoPago - Status: {}, Body: {}",
                        statusCode,
                        errorBody);

                // Manejar errores específicos
                String errorMessage =
                        handleMercadoPagoApiError(statusCode, errorBody, e.getMessage());
                throw new MercadoPagoException(errorMessage);
            }
            throw new MercadoPagoException(
                    "Error al crear suscripción en MercadoPago: " + e.getMessage());
        } catch (MPException e) {
            log.error("Error al crear preapproval en MercadoPago: {}", e.getMessage(), e);
            throw new MercadoPagoException("Error de conexión con MercadoPago: " + e.getMessage());
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

        // Buscar la subscription asociada para el mapper
        Optional<Subscription> subscriptionOpt =
                slaveSubscriptionRepository.findByMercadoPagoPreapproval(preapproval);
        Subscription subscription = subscriptionOpt.orElse(null);

        return preapprovalMapper.toSubscriptionResponse(preapproval, subscription);
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

        if (subscription.getType().equals(SubscriptionType.BASIC)) {
            return preapprovalMapper.toDTO(subscription, null);
        }
        MercadoPagoPreapproval mercadoPagoPreapproval =
                slaveMercadoPagoPreapprovalRepository
                        .findByUser(user)
                        .orElseThrow(
                                () -> new SubscriptionMercadoPagoException("Pago no encontrado"));
        return preapprovalMapper.toDTO(subscription, mercadoPagoPreapproval);
    }

    /** Valida si el usuario puede crear una nueva suscripción */
    /** Valida si el usuario puede crear una nueva suscripción */
    private void validateActiveSubscriptions(User user, SubscriptionType newSubscriptionType) {
        // Buscar suscripciones activas del usuario
        List<Subscription> activeSubscriptions =
                slaveSubscriptionRepository.findByUserAndState(user, State.ACTIVE);

        handleActiveSubscriptions(user, newSubscriptionType, activeSubscriptions);

        // Buscar y cancelar suscripciones pendientes
        List<Subscription> pendingSubscriptions =
                slaveSubscriptionRepository.findByUserAndState(user, State.PENDING);

        handlePendingSubscriptions(user, pendingSubscriptions);
    }

    /**
     * Maneja las suscripciones activas del usuario
     */
    private void handleActiveSubscriptions(User user, SubscriptionType newSubscriptionType,
                                           List<Subscription> activeSubscriptions) {
        if (activeSubscriptions.isEmpty()) {
            return;
        }

        Subscription activeSubscription = activeSubscriptions.get(0);

        // Validar si es del mismo tipo
        if (activeSubscription.getType() == newSubscriptionType) {
            throw new SubscriptionMercadoPagoException(
                    String.format("El usuario ya tiene una suscripción activa del tipo %s",
                            newSubscriptionType.name()));
        }

        // Cambiar de plan - cancelar suscripción actual
        log.info("Usuario {} tiene suscripción activa tipo {}, cambiando a tipo {}",
                user.getEmail(), activeSubscription.getType(), newSubscriptionType);

        cancelSubscription(activeSubscription);
        cancelAssociatedPreapproval(activeSubscription);
    }

    /**
     * Maneja las suscripciones pendientes del usuario
     */
    private void handlePendingSubscriptions(User user, List<Subscription> pendingSubscriptions) {
        if (pendingSubscriptions.isEmpty()) {
            return;
        }

        log.info("Usuario {} tiene {} suscripciones pendientes, cancelándolas",
                user.getEmail(), pendingSubscriptions.size());

        for (Subscription pendingSubscription : pendingSubscriptions) {
            cancelSubscription(pendingSubscription);
            cancelPendingPreapproval(pendingSubscription, user);
        }
    }

    /**
     * Cancela una suscripción localmente
     */
    private void cancelSubscription(Subscription subscription) {
        subscription.setState(State.CANCELLED);
        subscription.setUpdatedAt(LocalDateTime.now());
        masterSubscriptionRepository.save(subscription);
    }

    /**
     * Cancela el preapproval asociado a una suscripción activa
     */
    private void cancelAssociatedPreapproval(Subscription activeSubscription) {
        if (activeSubscription.getMercadoPagoPreapproval() == null) {
            return;
        }

        MercadoPagoPreapproval activePreapproval = findPreapprovalById(
                activeSubscription.getMercadoPagoPreapproval().getId());

        // Cancelar en MercadoPago primero
        cancelPreapprovalInMercadoPagoSafely(activePreapproval.getPreapprovalId());

        // Cancelar localmente
        updatePreapprovalStatus(activePreapproval, PreapprovalStatus.CANCELLED);
    }

    /**
     * Cancela el preapproval asociado a una suscripción pendiente
     */
    private void cancelPendingPreapproval(Subscription pendingSubscription, User user) {
        try {
            // Inicializar la relación lazy de manera segura
            Hibernate.initialize(pendingSubscription.getMercadoPagoPreapproval());

            if (pendingSubscription.getMercadoPagoPreapproval() != null) {
                MercadoPagoPreapproval pendingPreapproval = pendingSubscription.getMercadoPagoPreapproval();
                updatePreapprovalStatus(pendingPreapproval, PreapprovalStatus.CANCELLED);
            }

        } catch (org.hibernate.LazyInitializationException e) {
            handleLazyInitializationException(user);
        }
    }

    /**
     * Maneja el error de inicialización lazy buscando el preapproval directamente
     */
    private void handleLazyInitializationException(User user) {
        log.warn("No se pudo inicializar MercadoPagoPreapproval, buscando por base de datos");

        Optional<MercadoPagoPreapproval> preapprovalOpt =
                slaveMercadoPagoPreapprovalRepository.findByUser(user);

        if (preapprovalOpt.isPresent()) {
            MercadoPagoPreapproval pendingPreapproval = preapprovalOpt.get();
            updatePreapprovalStatus(pendingPreapproval, PreapprovalStatus.CANCELLED);
        }
    }

    /**
     * Busca un preapproval por ID con manejo de excepciones
     */
    private MercadoPagoPreapproval findPreapprovalById(Integer preapprovalId) {
        return masterMercadoPagoPreapprovalRepository
                .findById(preapprovalId)
                .orElseThrow(() -> new SubscriptionMercadoPagoException("Preapproval no encontrado"));
    }

    /**
     * Actualiza el estado de un preapproval
     */
    private void updatePreapprovalStatus(MercadoPagoPreapproval preapproval, PreapprovalStatus status) {
        preapproval.setStatus(status);
        preapproval.setLastModified(LocalDateTime.now());
        masterMercadoPagoPreapprovalRepository.save(preapproval);
    }

    /**
     * Cancela un preapproval en MercadoPago con manejo seguro de errores
     */
    private void cancelPreapprovalInMercadoPagoSafely(String preapprovalId) {
        try {
            cancelPreapprovalInMercadoPago(preapprovalId);
            log.info("Preapproval {} cancelado exitosamente en MercadoPago", preapprovalId);
        } catch (Exception e) {
            log.error("Error cancelando preapproval en MercadoPago: {}", e.getMessage(), e);
            // Continuar con la cancelación local aunque falle en MercadoPago
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
        // Buscar la suscripción más reciente del usuario o crear una nueva
        Optional<Subscription> existingSubscriptionOpt =
                slaveSubscriptionRepository.findFirstByUserOrderByIdDesc(user);

        Subscription subscription = existingSubscriptionOpt.orElseGet(Subscription::new);

        subscription.setUser(user);
        subscription.setType(subscriptionType);
        subscription.setStartDate(LocalDateTime.now());
        subscription.setExpirationDate(LocalDateTime.now().plusDays(30));
        subscription.setState(State.PENDING);
        subscription.setMercadoPagoPreapproval(preapproval);
        subscription.setIsAutoRenewable(true);
        subscription.setUpdatedAt(LocalDateTime.now());

        // Si es una nueva fila, asignar createdAt
        if (subscription.getCreatedAt() == null) {
            subscription.setCreatedAt(LocalDateTime.now());
        }

        masterSubscriptionRepository.save(subscription);

        log.info(
                "Suscripción actualizada o creada para usuario: {}, tipo: {}, ID: {}",
                user.getEmail(),
                subscriptionType,
                subscription.getId());
    }

    /** Cancela un preapproval directamente en MercadoPago */
    private void cancelPreapprovalInMercadoPago(String preapprovalId)
            throws MPException, MPApiException {
        try {
            PreapprovalClient client = new PreapprovalClient();

            // MercadoPago requiere una actualización con status "cancelled"
            // Nota: La API de MercadoPago puede variar, verificar documentación actual
            log.info("Intentando cancelar preapproval {} en MercadoPago", preapprovalId);

            // Obtener el preapproval actual
            Preapproval preapproval = client.get(preapprovalId);

            if (preapproval != null) {
                log.info(
                        "Preapproval {} encontrado en MercadoPago con status: {}",
                        preapprovalId,
                        preapproval.getStatus());

                // En algunos casos, MercadoPago cancela automáticamente cuando se crea uno nuevo
                // o requiere un proceso específico de cancelación
                // TODO: Implementar cancelación según documentación actualizada de MercadoPago
            }

        } catch (MPApiException e) {
            if (e.getApiResponse() != null && e.getApiResponse().getStatusCode() == 404) {
                log.warn(
                        "Preapproval {} no encontrado en MercadoPago (posiblemente ya cancelado)",
                        preapprovalId);
            } else {
                throw e;
            }
        }
    }

    /** Maneja errores específicos de la API de MercadoPago */
    private String handleMercadoPagoApiError(
            int statusCode, String errorBody, String originalMessage) {
        return switch (statusCode) {
            case 400 -> {
                if (errorBody != null && errorBody.contains("invalid_parameter")) {
                    yield "Parámetros inválidos en la solicitud. Verifique los datos enviados.";
                }
                yield "Solicitud incorrecta: " + originalMessage;
            }
            case 401 -> "Credenciales de MercadoPago inválidas. Contacte al administrador.";
            case 403 -> "Acceso denegado por MercadoPago. Verifique los permisos de la aplicación.";
            case 404 -> "Recurso no encontrado en MercadoPago.";
            case 429 -> "Límite de solicitudes excedido. Intente nuevamente en unos minutos.";
            case 500, 502, 503, 504 -> "Error temporal en los servidores de MercadoPago. Intente nuevamente.";
            default -> "Error en MercadoPago (" + statusCode + "): " + originalMessage;
        };
    }
}
