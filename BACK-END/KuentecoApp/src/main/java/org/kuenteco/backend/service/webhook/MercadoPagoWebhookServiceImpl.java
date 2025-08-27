package org.kuenteco.backend.service.webhook;

import com.mercadopago.client.payment.PaymentClient;
import com.mercadopago.client.preapproval.PreapprovalClient;
import com.mercadopago.exceptions.MPApiException;
import com.mercadopago.exceptions.MPException;
import com.mercadopago.resources.payment.Payment;
import com.mercadopago.resources.preapproval.Preapproval;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.entity.MercadoPagoPayment;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.enums.PaymentStatus;
import org.kuenteco.backend.enums.PreapprovalStatus;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.repository.master.MasterMercadoPagoPaymentRepository;
import org.kuenteco.backend.repository.master.MasterMercadoPagoPreapprovalRepository;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveMercadoPagoPaymentRepository;
import org.kuenteco.backend.repository.slave.SlaveMercadoPagoPreapprovalRepository;
import org.kuenteco.backend.repository.slave.SlaveSubscriptionRepository;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class MercadoPagoWebhookServiceImpl implements MercadoPagoWebhookService {

    private final MasterMercadoPagoPreapprovalRepository masterMercadoPagoPreapprovalRepository;
    private final SlaveMercadoPagoPreapprovalRepository slaveMercadoPagoPreapprovalRepository;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final SlaveSubscriptionRepository slaveSubscriptionRepository;
    private final MasterMercadoPagoPaymentRepository masterMercadoPagoPaymentRepository;
    private final SlaveMercadoPagoPaymentRepository slaveMercadoPagoPaymentRepository;
    private final MercadoPagoWebhookValidationService validationService;

    @Override
    @Async
    @Transactional
    public void processSubscriptionAuthorizedPaymentWebhook(
            String paymentId, String action, Map<String, Object> notification) {
        try {
            log.info(
                    "Procesando webhook de subscription_authorized_payment: ID={}, action={}",
                    paymentId,
                    action);

            // Obtener información del pago desde MercadoPago con reintentos
            PaymentClient client = new PaymentClient();
            Payment payment = null;
            int maxRetries = 3;
            int retryCount = 0;
            boolean success = false;

            while (retryCount < maxRetries && !success) {
                try {
                    // Esperar antes de reintentar (excepto en el primer intento)
                    if (retryCount > 0) {
                        try {
                            Thread.sleep(2000 * retryCount); // Espera progresiva: 2s, 4s
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                            return;
                        }
                    }

                    payment = client.get(Long.valueOf(paymentId));
                    success = true;
                    log.info(
                            "Pago autorizado obtenido exitosamente en el intento {}: {}",
                            retryCount + 1,
                            paymentId);
                } catch (MPApiException e) {
                    retryCount++;
                    log.warn(
                            "Intento {} fallido al obtener pago autorizado {}: {}",
                            retryCount,
                            paymentId,
                            e.getMessage());

                    if (e.getApiResponse() != null && e.getApiResponse().getStatusCode() == 404) {
                        if (retryCount >= maxRetries) {
                            log.warn(
                                    "Pago autorizado {} no encontrado después de {} reintentos",
                                    paymentId,
                                    maxRetries);

                            // Guardar el pago como pendiente para procesamiento posterior
                            savePendingAuthorizedPaymentForLater(paymentId, action);
                            return;
                        }
                    } else {
                        // Si no es un error 404, no reintentar
                        log.error(
                                "Error de API de MercadoPago al obtener pago autorizado {}: {}",
                                paymentId,
                                e.getMessage());
                        return;
                    }
                }
            }

            if (!success || payment == null) {
                log.error(
                        "No se pudo obtener el pago autorizado {} después de {} reintentos",
                        paymentId,
                        maxRetries);
                return;
            }

            // Buscar el preapproval asociado
            String externalReference = payment.getExternalReference();
            if (externalReference != null) {
                Optional<MercadoPagoPreapproval> preapprovalOpt =
                        slaveMercadoPagoPreapprovalRepository.findByExternalReference(
                                externalReference);

                if (preapprovalOpt.isPresent()) {
                    MercadoPagoPreapproval preapproval = preapprovalOpt.get();

                    // Actualizar el preapproval con la información del pago
                    preapproval.setPaymentMethodId(payment.getPaymentMethodId());
                    preapproval.setLastModified(LocalDateTime.now());
                    masterMercadoPagoPreapprovalRepository.save(preapproval);

                    // Procesar el pago
                    if ("approved".equals(payment.getStatus())) {
                        handlePaymentApprovedForSubscription(preapproval, payment);
                    }
                } else {
                    log.warn(
                            "No se encontró preapproval para external_reference: {}",
                            externalReference);
                }
            } else {
                log.warn("Pago autorizado {} no tiene external_reference", paymentId);
            }

            log.info(
                    "Webhook de subscription_authorized_payment procesado exitosamente: {}",
                    paymentId);
        } catch (Exception e) {
            log.error(
                    "Error procesando webhook de subscription_authorized_payment: {}",
                    e.getMessage(),
                    e);
        }
    }

    /** Guarda un registro de pago autorizado pendiente para procesamiento posterior */
    private void savePendingAuthorizedPaymentForLater(String paymentId, String action) {
        try {
            // Verificar si ya existe un registro pendiente para este pago
            Optional<MercadoPagoPayment> existingPaymentOpt =
                    slaveMercadoPagoPaymentRepository.findByPaymentId(paymentId);

            if (existingPaymentOpt.isPresent()) {
                log.warn("Ya existe un registro para el pago autorizado pendiente: {}", paymentId);
                return;
            }

            MercadoPagoPreapproval preapproval = null;

            // Intentar obtener el pago desde MercadoPago para extraer el external_reference
            PaymentClient client = new PaymentClient();

            try {
                Payment payment = client.get(Long.valueOf(paymentId));
                String externalReference = payment.getExternalReference();

                if (externalReference != null) {
                    // Buscar preapproval por external_reference
                    Optional<MercadoPagoPreapproval> preapprovalOpt =
                            slaveMercadoPagoPreapprovalRepository.findByExternalReference(
                                    externalReference);

                    if (preapprovalOpt.isPresent()) {
                        preapproval = preapprovalOpt.get();
                        log.info(
                                "Preapproval encontrado para external_reference {}: {}",
                                externalReference,
                                preapproval.getPreapprovalId());
                    }
                }
            } catch (MPApiException e) {
                log.warn(
                        "No se pudo obtener el pago autorizado {} para asociarlo a un preapproval: {}",
                        paymentId,
                        e.getMessage());

                // Si no podemos obtener el pago, intentamos encontrar el preapproval más reciente
                try {
                    List<MercadoPagoPreapproval> recentPreapprovals =
                            slaveMercadoPagoPreapprovalRepository
                                    .findTop10ByOrderByLastModifiedDesc();

                    if (!recentPreapprovals.isEmpty()) {
                        preapproval = recentPreapprovals.get(0);
                        log.info(
                                "Usando preapproval más reciente como fallback para pago autorizado: {}",
                                preapproval.getPreapprovalId());
                    }
                } catch (Exception ex) {
                    log.warn(
                            "No se pudo encontrar un preapproval de fallback para pago autorizado: {}",
                            ex.getMessage());
                }
            }

            // Crear un registro de pago pendiente (ahora preapproval puede ser null)
            MercadoPagoPayment pendingPayment =
                    MercadoPagoPayment.builder()
                            .paymentId(paymentId)
                            .preapproval(
                                    preapproval) // Puede ser null si no encontramos el preapproval
                            .status(PaymentStatus.PENDING)
                            .dateCreated(LocalDateTime.now())
                            .dateLastUpdated(LocalDateTime.now())
                            .description("Pago autorizado pendiente de procesamiento")
                            .build();

            masterMercadoPagoPaymentRepository.save(pendingPayment);
            log.info(
                    "Pago autorizado guardado como pendiente para procesamiento posterior: {}",
                    paymentId);

        } catch (Exception e) {
            log.error(
                    "Error guardando pago autorizado pendiente {}: {}",
                    paymentId,
                    e.getMessage(),
                    e);
        }
    }

    @Override
    @Async
    @Transactional
    public void processPreapprovalWebhook(
            String preapprovalId, String action, Map<String, Object> notification) {
        try {
            log.info("Procesando webhook de preapproval: ID={}, action={}", preapprovalId, action);

            // Buscar el preapproval en nuestra base de datos
            Optional<MercadoPagoPreapproval> preapprovalOpt =
                    slaveMercadoPagoPreapprovalRepository.findByPreapprovalId(preapprovalId);

            if (preapprovalOpt.isEmpty()) {
                log.warn("Preapproval no encontrado en base de datos: {}", preapprovalId);
                return;
            }

            MercadoPagoPreapproval localPreapproval = preapprovalOpt.get();

            // Obtener datos actualizados de MercadoPago
            PreapprovalClient client = new PreapprovalClient();
            Preapproval mpPreapproval = client.get(preapprovalId);

            // Actualizar datos locales con información de MercadoPago
            updateLocalPreapprovalFromMP(localPreapproval, mpPreapproval);

            // Procesar según el tipo de acción
            switch (action) {
                case "created", "preapproval.created" ->
                        handlePreapprovalCreated(localPreapproval, mpPreapproval);
                case "updated", "preapproval.updated" ->
                        handlePreapprovalUpdated(localPreapproval, mpPreapproval);
                case "authorized", "preapproval.authorized" ->
                        handlePreapprovalAuthorized(localPreapproval, mpPreapproval);
                case "pending", "preapproval.pending" ->
                        handlePreapprovalPending(localPreapproval, mpPreapproval);
                case "cancelled", "preapproval.cancelled" ->
                        handlePreapprovalCancelled(localPreapproval, mpPreapproval);
                case "rejected", "preapproval.rejected" ->
                        handlePreapprovalRejected(localPreapproval, mpPreapproval);
                case "paused", "preapproval.paused" ->
                        handlePreapprovalPaused(localPreapproval, mpPreapproval);
                default -> log.warn("Acción de preapproval no reconocida: {}", action);
            }

            log.info("Webhook de preapproval procesado exitosamente: {}", preapprovalId);
        } catch (MPException | MPApiException e) {
            log.error(
                    "Error al obtener datos del preapproval desde MercadoPago: {}",
                    e.getMessage(),
                    e);
        } catch (Exception e) {
            log.error("Error procesando webhook de preapproval: {}", e.getMessage(), e);
        }
    }

    @Override
    @Async
    public void processPaymentWebhook(
            String paymentId, String action, Map<String, Object> notification) {
        try {
            log.info("Procesando webhook de payment: ID={}, action={}", paymentId, action);

            // Obtener información del pago desde MercadoPago con reintentos
            PaymentClient client = new PaymentClient();
            Payment payment = null;
            int maxRetries = 3;
            int retryCount = 0;
            boolean success = false;

            while (retryCount < maxRetries && !success) {
                try {
                    // Esperar antes de reintentar (excepto en el primer intento)
                    if (retryCount > 0) {
                        try {
                            Thread.sleep(2000 * retryCount); // Espera progresiva: 2s, 4s
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                            return;
                        }
                    }

                    payment = client.get(Long.valueOf(paymentId));
                    success = true;
                    log.info("Pago obtenido exitosamente en el intento {}: {}", retryCount + 1, paymentId);
                } catch (MPApiException e) {
                    retryCount++;
                    log.warn("Intento {} fallido al obtener pago {}: {}", retryCount, paymentId, e.getMessage());

                    if (e.getApiResponse() != null) {
                        int statusCode = e.getApiResponse().getStatusCode();
                        String content = e.getApiResponse().getContent();
                        log.error("MercadoPago API Error - Status: {}, Content: {}", statusCode, content);
                        
                        if (statusCode == 404) {
                            if (retryCount >= maxRetries) {
                                log.warn("Pago {} no encontrado después de {} reintentos. " +
                                       "Esto es NORMAL en sandbox - MercadoPago envía webhooks de pagos simulados.", 
                                       paymentId, maxRetries);
                                handleMissingPayment(paymentId, action);
                                return;
                            }
                        } else if (statusCode == 401) {
                            log.error("Error de autenticación - verificar access token");
                            return;
                        } else if (statusCode == 403) {
                            log.error("Sin permisos para acceder al pago {}", paymentId);
                            return;
                        } else if (statusCode >= 500) {
                            log.error("Error del servidor de MercadoPago - reintentando...");
                            // Continuar con reintentos para errores de servidor
                        } else {
                            // Otros errores 4xx no reintentar
                            log.error("Error cliente (4xx) - no reintentando");
                            return;
                        }
                    } else {
                        log.error("Error de API sin respuesta: {}", e.getMessage());
                        return;
                    }
                }
            }

            if (!success || payment == null) {
                log.error("No se pudo obtener el pago {} después de {} reintentos", paymentId, maxRetries);
                return;
            }

            // Procesar según el tipo de acción
            switch (action) {
                case "payment.created" -> handlePaymentCreated(payment);
                case "payment.updated" -> handlePaymentUpdated(payment);
                default -> log.warn("Acción de payment no reconocida: {}", action);
            }

            log.info("Webhook de payment procesado exitosamente: {}", paymentId);
        } catch (MPException e) {
            log.error("Error de conexión con MercadoPago al procesar payment {}: {}", paymentId, e.getMessage(), e);
        } catch (Exception e) {
            log.error("Error procesando webhook de payment: {}", e.getMessage(), e);
        }
    }

    /**
     * Maneja el caso cuando un pago no se encuentra en MercadoPago
     */
    private void handleMissingPayment(String paymentId, String action) {
        try {
            log.info("Procesando pago no encontrado: ID={}, action={}", paymentId, action);

            // Buscar si ya existe un registro para este pago
            Optional<MercadoPagoPayment> existingPaymentOpt =
                    slaveMercadoPagoPaymentRepository.findByPaymentId(paymentId);

            MercadoPagoPayment payment;

            if (existingPaymentOpt.isPresent()) {
                payment = existingPaymentOpt.get();
                log.info("Pago existente encontrado: {}", paymentId);
            } else {
                // Crear un registro de pago rechazado
                payment = MercadoPagoPayment.builder()
                        .paymentId(paymentId)
                        .status(PaymentStatus.DECLINED) // Asumimos que fue rechazado
                        .statusDetail("Payment not found in MercadoPago API")
                        .dateCreated(LocalDateTime.now())
                        .dateLastUpdated(LocalDateTime.now())
                        .description("Payment not found - assumed rejected")
                        .build();

                // IMPORTANTE: Solo asociar al preapproval más reciente si no encontramos otra forma
                // En producción, esto puede causar problemas si hay múltiples usuarios creando suscripciones
                try {
                    // Buscar preapprovals creados recientemente (últimos 15 minutos)
                    LocalDateTime recentThreshold = LocalDateTime.now().minusMinutes(15);
                    List<MercadoPagoPreapproval> recentPreapprovals =
                            slaveMercadoPagoPreapprovalRepository
                                .findByDateCreatedAfterOrderByDateCreatedDesc(recentThreshold);

                    if (!recentPreapprovals.isEmpty()) {
                        MercadoPagoPreapproval mostRecentPreapproval = recentPreapprovals.get(0);
                        payment.setPreapproval(mostRecentPreapproval);
                        log.warn("Pago rechazado asociado al preapproval más reciente (último 15 min): {}. " +
                               "ESTO PUEDE SER PROBLEMÁTICO en producción con múltiples usuarios.",
                               mostRecentPreapproval.getPreapprovalId());
                    } else {
                        log.warn("No se encontraron preapprovals recientes para asociar el pago rechazado: {}", paymentId);
                    }
                } catch (Exception e) {
                    log.warn("No se pudo asociar el pago rechazado a un preapproval: {}", e.getMessage());
                }

                masterMercadoPagoPaymentRepository.save(payment);
                log.info("Pago rechazado guardado: {}", paymentId);
            }

            // Si el pago está marcado como rechazado, manejar la cancelación de la suscripción
            if (payment.getStatus() == PaymentStatus.DECLINED && payment.getPreapproval() != null) {
                Optional<Subscription> subscriptionOpt =
                        slaveSubscriptionRepository.findByMercadoPagoPreapproval(payment.getPreapproval());

                if (subscriptionOpt.isPresent()) {
                    Subscription subscription = subscriptionOpt.get();
                    subscription.setState(State.CANCELLED);
                    subscription.setUpdatedAt(LocalDateTime.now());
                    masterSubscriptionRepository.save(subscription);

                    // También actualizar el preapproval
                    MercadoPagoPreapproval preapproval = payment.getPreapproval();
                    preapproval.setStatus(PreapprovalStatus.CANCELLED);
                    preapproval.setLastModified(LocalDateTime.now());
                    masterMercadoPagoPreapprovalRepository.save(preapproval);

                    log.info("Suscripción cancelada por pago rechazado: {}", subscription.getId());
                }
            }

        } catch (Exception e) {
            log.error("Error manejando pago no encontrado {}: {}", paymentId, e.getMessage(), e);
        }
    }

    @Override
    @Async
    public void processGenericWebhook(Map<String, Object> notification) {
        try {
            log.info("Procesando webhook genérico: {}", notification);

            String type = (String) notification.get("type");
            String action = (String) notification.get("action");

            log.info("Webhook genérico procesado: type={}, action={}", type, action);

        } catch (Exception e) {
            log.error("Error procesando webhook genérico: {}", e.getMessage(), e);
        }
    }

    @Override
    public boolean isValidWebhook(Map<String, Object> notification, Map<String, String> headers) {
        try {
            // Validaciones básicas
            if (notification == null || notification.isEmpty()) {
                log.warn("Notificación vacía o nula");
                return false;
            }

            String type = (String) notification.get("type");
            String action = (String) notification.get("action");
            Map<String, Object> data = (Map<String, Object>) notification.get("data");

            if (type == null && action == null) {
                log.warn("Notificación sin type ni action");
                return false;
            }

            if (data == null || data.get("id") == null) {
                log.warn("Notificación sin datos o ID");
                return false;
            }

            // Extraer data.id para validación de firma
            String dataId = validationService.extractDataId(notification, null);

            // Validar firma de MercadoPago (si está configurado el secret)
            if (headers.containsKey("x-signature")) {
                boolean isValidSignature =
                        validationService.isValidWebhookSignature(headers, dataId, null);
                if (!isValidSignature) {
                    log.warn("Firma del webhook inválida");
                    return false;
                }
                log.info("Webhook validado con firma de MercadoPago");
            } else {
                log.warn("Webhook sin firma x-signature - validación básica solamente");
            }

            return true;

        } catch (Exception e) {
            log.error("Error validando webhook: {}", e.getMessage(), e);
            return false;
        }
    }

    // ===========================================
    // MÉTODOS PRIVADOS PARA MANEJAR EVENTOS
    // ===========================================

    private void handlePreapprovalAuthorized(
            MercadoPagoPreapproval localPreapproval, Preapproval mpPreapproval) {
        log.info("Preapproval autorizado: {}", localPreapproval.getPreapprovalId());

        // Actualizar estado del preapproval
        localPreapproval.setStatus(PreapprovalStatus.AUTHORIZED);
        localPreapproval.setLastModified(LocalDateTime.now());
        masterMercadoPagoPreapprovalRepository.save(localPreapproval);

        // Activar la suscripción
        Optional<Subscription> subscriptionOpt =
                slaveSubscriptionRepository.findByMercadoPagoPreapproval(localPreapproval);
        if (subscriptionOpt.isPresent()) {
            Subscription subscription = subscriptionOpt.get();
            subscription.setState(State.ACTIVE);
            subscription.setUpdatedAt(LocalDateTime.now());
            masterSubscriptionRepository.save(subscription);

            log.info("Suscripción activada: {}", subscription.getId());
        }
    }

    private void handlePreapprovalPending(
            MercadoPagoPreapproval localPreapproval, Preapproval mpPreapproval) {
        log.info("Preapproval pendiente: {}", localPreapproval.getPreapprovalId());

        localPreapproval.setStatus(PreapprovalStatus.PENDING);
        localPreapproval.setLastModified(LocalDateTime.now());
        masterMercadoPagoPreapprovalRepository.save(localPreapproval);

        // La suscripción permanece en estado PENDING
        Optional<Subscription> subscriptionOpt =
                slaveSubscriptionRepository.findByMercadoPagoPreapproval(localPreapproval);
        if (subscriptionOpt.isPresent()) {
            Subscription subscription = subscriptionOpt.get();
            subscription.setState(State.PENDING);
            subscription.setUpdatedAt(LocalDateTime.now());
            masterSubscriptionRepository.save(subscription);
        }
    }

    private void handlePreapprovalCancelled(
            MercadoPagoPreapproval localPreapproval, Preapproval mpPreapproval) {
        log.info("Preapproval cancelado: {}", localPreapproval.getPreapprovalId());

        localPreapproval.setStatus(PreapprovalStatus.CANCELLED);
        localPreapproval.setLastModified(LocalDateTime.now());
        masterMercadoPagoPreapprovalRepository.save(localPreapproval);

        // Cancelar la suscripción
        Optional<Subscription> subscriptionOpt =
                slaveSubscriptionRepository.findByMercadoPagoPreapproval(localPreapproval);
        if (subscriptionOpt.isPresent()) {
            Subscription subscription = subscriptionOpt.get();
            subscription.setState(State.CANCELLED);
            subscription.setUpdatedAt(LocalDateTime.now());
            masterSubscriptionRepository.save(subscription);

            log.info("Suscripción cancelada: {}", subscription.getId());
        }
    }

    private void handlePreapprovalRejected(
            MercadoPagoPreapproval localPreapproval, Preapproval mpPreapproval) {
        log.info("Preapproval rechazado: {}", localPreapproval.getPreapprovalId());

        localPreapproval.setStatus(PreapprovalStatus.REJECTED);
        localPreapproval.setLastModified(LocalDateTime.now());
        masterMercadoPagoPreapprovalRepository.save(localPreapproval);

        // Rechazar la suscripción
        Optional<Subscription> subscriptionOpt =
                slaveSubscriptionRepository.findByMercadoPagoPreapproval(localPreapproval);
        if (subscriptionOpt.isPresent()) {
            Subscription subscription = subscriptionOpt.get();
            subscription.setState(State.CANCELLED); // No hay estado REJECTED en Subscription
            subscription.setUpdatedAt(LocalDateTime.now());
            masterSubscriptionRepository.save(subscription);
        }
    }

    private void handlePreapprovalPaused(
            MercadoPagoPreapproval localPreapproval, Preapproval mpPreapproval) {
        log.info("Preapproval pausado: {}", localPreapproval.getPreapprovalId());

        localPreapproval.setStatus(PreapprovalStatus.PAUSED);
        localPreapproval.setLastModified(LocalDateTime.now());
        masterMercadoPagoPreapprovalRepository.save(localPreapproval);

        // Pausar la suscripción (usar estado CANCELLED como pausa)
        Optional<Subscription> subscriptionOpt =
                slaveSubscriptionRepository.findByMercadoPagoPreapproval(localPreapproval);
        if (subscriptionOpt.isPresent()) {
            Subscription subscription = subscriptionOpt.get();
            subscription.setState(State.CANCELLED);
            subscription.setUpdatedAt(LocalDateTime.now());
            masterSubscriptionRepository.save(subscription);
        }
    }

    private void handlePaymentCreated(Payment payment) {
        log.info("Pago creado: ID={}, status={}", payment.getId(), payment.getStatus());
        try {
            // Buscar si ya existe el pago en base de datos
            Optional<MercadoPagoPayment> existingPaymentOpt =
                    slaveMercadoPagoPaymentRepository.findByPaymentId(
                            String.valueOf(payment.getId()));
            if (existingPaymentOpt.isPresent()) {
                log.warn("Pago ya existe en base de datos: {}", payment.getId());
                return;
            }

            // Buscar el preapproval asociado usando el external_reference
            String externalReference = payment.getExternalReference();
            if (externalReference == null) {
                log.warn("Pago sin external_reference: {}", payment.getId());
                return;
            }

            // Buscar preapproval por external_reference
            Optional<MercadoPagoPreapproval> preapprovalOpt =
                    slaveMercadoPagoPreapprovalRepository.findByExternalReference(
                            externalReference);
            if (preapprovalOpt.isEmpty()) {
                log.warn(
                        "No se encontró preapproval para external_reference: {}",
                        externalReference);
                return;
            }

            // Crear registro de pago
            MercadoPagoPayment newPayment = createPaymentFromMP(payment, preapprovalOpt.get());
            masterMercadoPagoPaymentRepository.save(newPayment);
            log.info("Pago creado en base de datos: ID={}", newPayment.getId());
        } catch (Exception e) {
            log.error("Error creando pago en base de datos: {}", e.getMessage(), e);
        }
    }

    private void handlePaymentUpdated(Payment payment) {
        log.info("Pago actualizado: ID={}, status={}", payment.getId(), payment.getStatus());
        try {
            // Buscar el pago en base de datos
            Optional<MercadoPagoPayment> paymentOpt =
                    slaveMercadoPagoPaymentRepository.findByPaymentId(
                            String.valueOf(payment.getId()));
            MercadoPagoPayment localPayment;
            if (paymentOpt.isEmpty()) {
                // Si no existe, crearlo (puede ser el primer webhook recibido)
                log.info("Pago no existe, creándolo: {}", payment.getId());
                handlePaymentCreated(payment);
                return;
            } else {
                localPayment = paymentOpt.get();
            }

            // Actualizar datos del pago
            updatePaymentFromMP(localPayment, payment);
            masterMercadoPagoPaymentRepository.save(localPayment);

            // Procesar según el estado del pago
            PaymentStatus newStatus = mapMPPaymentStatus(payment.getStatus());
            if (newStatus == PaymentStatus.APPROVED) {
                handlePaymentApproved(localPayment);
            } else if (newStatus == PaymentStatus.DECLINED || newStatus == PaymentStatus.ERROR) {
                handlePaymentFailed(localPayment);
            }
            log.info(
                    "Pago actualizado en base de datos: ID={}, status={}",
                    localPayment.getId(),
                    newStatus);
        } catch (Exception e) {
            log.error("Error actualizando pago en base de datos: {}", e.getMessage(), e);
        }
    }

    private void updateLocalPreapprovalFromMP(
            MercadoPagoPreapproval localPreapproval, Preapproval mpPreapproval) {
        // Actualizar datos locales con información fresca de MercadoPago
        if (mpPreapproval.getNextPaymentDate() != null) {
            localPreapproval.setNextPaymentDate(
                    mpPreapproval.getNextPaymentDate().toLocalDateTime());
        }

        if (mpPreapproval.getLastModified() != null) {
            localPreapproval.setLastModified(mpPreapproval.getLastModified().toLocalDateTime());
        }

        // Actualizar método de pago si está disponible
        if (mpPreapproval.getPaymentMethodId() != null) {
            localPreapproval.setPaymentMethodId(mpPreapproval.getPaymentMethodId());
        }

        // Actualizar información de la tarjeta si está disponible
        // Nota: La información de tarjeta puede venir en otros campos del preapproval
        // o requerir una consulta adicional a la API de MercadoPago

        // TODO: Implementar actualización de información de tarjeta si es necesario
        // La información de tarjeta generalmente viene en eventos de pago, no en preapproval
    }

    // ===========================================
    // MÉTODOS AUXILIARES PARA PAGOS
    // ===========================================

    private MercadoPagoPayment createPaymentFromMP(
            Payment payment, MercadoPagoPreapproval preapproval) {
        return MercadoPagoPayment.builder()
                .preapproval(preapproval)
                .paymentId(String.valueOf(payment.getId()))
                .transactionAmount(payment.getTransactionAmount())
                .currencyId(payment.getCurrencyId())
                .status(mapMPPaymentStatus(payment.getStatus()))
                .statusDetail(payment.getStatusDetail())
                .paymentMethodId(payment.getPaymentMethodId())
                .paymentTypeId(payment.getPaymentTypeId())
                .dateCreated(
                        payment.getDateCreated() != null
                                ? payment.getDateCreated().toLocalDateTime()
                                : LocalDateTime.now())
                .dateApproved(
                        payment.getDateApproved() != null
                                ? payment.getDateApproved().toLocalDateTime()
                                : null)
                .dateLastUpdated(
                        payment.getDateLastUpdated() != null
                                ? payment.getDateLastUpdated().toLocalDateTime()
                                : LocalDateTime.now())
                .authorizationCode(payment.getAuthorizationCode())
                .externalReference(payment.getExternalReference())
                .description(payment.getDescription())
                .build();
    }

    private void updatePaymentFromMP(MercadoPagoPayment localPayment, Payment payment) {
        localPayment.setTransactionAmount(payment.getTransactionAmount());
        localPayment.setStatus(mapMPPaymentStatus(payment.getStatus()));
        localPayment.setStatusDetail(payment.getStatusDetail());
        localPayment.setPaymentMethodId(payment.getPaymentMethodId());
        localPayment.setPaymentTypeId(payment.getPaymentTypeId());

        if (payment.getDateApproved() != null) {
            localPayment.setDateApproved(payment.getDateApproved().toLocalDateTime());
        }

        if (payment.getDateLastUpdated() != null) {
            localPayment.setDateLastUpdated(payment.getDateLastUpdated().toLocalDateTime());
        }

        localPayment.setAuthorizationCode(payment.getAuthorizationCode());
        localPayment.setDescription(payment.getDescription());
    }

    private PaymentStatus mapMPPaymentStatus(String mpStatus) {
        if (mpStatus == null) return PaymentStatus.PENDING;

        return switch (mpStatus.toLowerCase()) {
            case "approved" -> PaymentStatus.APPROVED;
            case "pending", "in_process", "in_mediation" -> PaymentStatus.PENDING;
            case "rejected", "cancelled" -> PaymentStatus.DECLINED;
            case "refunded", "charged_back" -> PaymentStatus.VOIDED;
            default -> PaymentStatus.ERROR;
        };
    }

    private void handlePaymentApproved(MercadoPagoPayment payment) {
        log.info("Procesando pago aprobado: ID={}", payment.getPaymentId());

        try {
            // Obtener la suscripción asociada
            MercadoPagoPreapproval preapproval = payment.getPreapproval();
            if (preapproval != null) {
                Optional<Subscription> subscriptionOpt =
                        slaveSubscriptionRepository.findByMercadoPagoPreapproval(preapproval);
                if (subscriptionOpt.isPresent()) {
                    Subscription subscription = subscriptionOpt.get();

                    // Extender la fecha de expiración de la suscripción
                    LocalDateTime currentExpiration = subscription.getExpirationDate();
                    LocalDateTime newExpiration;

                    // Si la suscripción ya expiró, extender desde hoy
                    if (currentExpiration.isBefore(LocalDateTime.now())) {
                        newExpiration = LocalDateTime.now().plusDays(30);
                    } else {
                        // Si aún está activa, extender desde la fecha actual de expiración
                        newExpiration = currentExpiration.plusDays(30);
                    }

                    subscription.setExpirationDate(newExpiration);
                    subscription.setState(State.ACTIVE);
                    subscription.setUpdatedAt(LocalDateTime.now());
                    masterSubscriptionRepository.save(subscription);

                    // Actualizar la fecha del próximo pago en el preapproval
                    preapproval.setNextPaymentDate(newExpiration);
                    preapproval.setLastModified(LocalDateTime.now());
                    masterMercadoPagoPreapprovalRepository.save(preapproval);

                    log.info(
                            "Suscripción extendida hasta: {}, subscription ID: {}",
                            newExpiration,
                            subscription.getId());
                }
            }

        } catch (Exception e) {
            log.error("Error procesando pago aprobado: {}", e.getMessage(), e);
        }
    }

    private void handlePaymentFailed(MercadoPagoPayment payment) {
        log.info("Procesando pago fallido: ID={}", payment.getPaymentId());

        try {
            // Obtener la suscripción asociada
            MercadoPagoPreapproval preapproval = payment.getPreapproval();
            if (preapproval != null) {
                Optional<Subscription> subscriptionOpt =
                        slaveSubscriptionRepository.findByMercadoPagoPreapproval(preapproval);
                if (subscriptionOpt.isPresent()) {
                    Subscription subscription = subscriptionOpt.get();

                    // Si la suscripción ya expiró, marcarla como vencida
                    if (subscription.getExpirationDate().isBefore(LocalDateTime.now())) {
                        subscription.setState(State.CANCELLED); // No hay estado EXPIRED
                        subscription.setUpdatedAt(LocalDateTime.now());
                        masterSubscriptionRepository.save(subscription);

                        log.info(
                                "Suscripción marcada como vencida por pago fallido: {}",
                                subscription.getId());
                    }
                }

                // TODO: Implementar lógica adicional:
                // - Enviar email de notificación de pago fallido
                // - Programar reintento automático
                // - Dar período de gracia antes de cancelar
            }

        } catch (Exception e) {
            log.error("Error procesando pago fallido: {}", e.getMessage(), e);
        }
    }

    /**
     * Maneja la aprobación de un pago para una suscripción con pago autorizado Este método se llama
     * específicamente cuando se recibe un webhook de subscription_authorized_payment
     */
    private void handlePaymentApprovedForSubscription(
            MercadoPagoPreapproval preapproval, Payment payment) {
        log.info(
                "Procesando pago aprobado para suscripción: preapproval={}, payment={}",
                preapproval.getPreapprovalId(),
                payment.getId());

        try {
            // Buscar la suscripción asociada al preapproval
            Optional<Subscription> subscriptionOpt =
                    slaveSubscriptionRepository.findByMercadoPagoPreapproval(preapproval);

            if (subscriptionOpt.isPresent()) {
                Subscription subscription = subscriptionOpt.get();

                // Actualizar estado de la suscripción a ACTIVO
                subscription.setState(State.ACTIVE);
                subscription.setUpdatedAt(LocalDateTime.now());

                // Calcular nueva fecha de expiración
                LocalDateTime currentExpiration = subscription.getExpirationDate();
                LocalDateTime newExpiration;

                // Si la suscripción ya expiró, extender desde hoy
                if (currentExpiration.isBefore(LocalDateTime.now())) {
                    newExpiration = LocalDateTime.now().plusDays(30);
                } else {
                    // Si aún está activa, extender desde la fecha actual de expiración
                    newExpiration = currentExpiration.plusDays(30);
                }

                subscription.setExpirationDate(newExpiration);
                masterSubscriptionRepository.save(subscription);

                // Actualizar el preapproval
                preapproval.setStatus(PreapprovalStatus.AUTHORIZED);
                preapproval.setLastModified(LocalDateTime.now());
                preapproval.setNextPaymentDate(newExpiration);

                // Actualizar información de pago si está disponible
                if (payment.getPaymentMethodId() != null) {
                    preapproval.setPaymentMethodId(payment.getPaymentMethodId());
                }

                masterMercadoPagoPreapprovalRepository.save(preapproval);

                log.info(
                        "Suscripción actualizada con pago aprobado: subscriptionId={}, nuevaExpiracion={}",
                        subscription.getId(),
                        newExpiration);

                // Aquí podrías agregar lógica adicional como:
                // - Enviar email de confirmación al usuario
                // - Actualizar estadísticas
                // - Activar features premium para el usuario

            } else {
                log.warn(
                        "No se encontró suscripción para el preapproval: {}",
                        preapproval.getPreapprovalId());
            }

        } catch (Exception e) {
            log.error("Error procesando pago aprobado para suscripción: {}", e.getMessage(), e);
            // Aquí podrías agregar lógica de reintento o notificación a administración
        }
    }

    /** Maneja la creación de un preapproval */
    private void handlePreapprovalCreated(
            MercadoPagoPreapproval localPreapproval, Preapproval mpPreapproval) {
        log.info("Preapproval creado: {}", localPreapproval.getPreapprovalId());

        // Actualizar estado del preapproval
        if (mpPreapproval.getStatus() != null) {
            PreapprovalStatus status = mapMPPreapprovalStatus(mpPreapproval.getStatus());
            localPreapproval.setStatus(status);
        }
        localPreapproval.setLastModified(LocalDateTime.now());
        masterMercadoPagoPreapprovalRepository.save(localPreapproval);

        // La suscripción permanece en estado PENDING hasta que se autorice el pago
        Optional<Subscription> subscriptionOpt =
                slaveSubscriptionRepository.findByMercadoPagoPreapproval(localPreapproval);
        if (subscriptionOpt.isPresent()) {
            Subscription subscription = subscriptionOpt.get();
            subscription.setState(State.PENDING);
            subscription.setUpdatedAt(LocalDateTime.now());
            masterSubscriptionRepository.save(subscription);
        }
    }

    /** Maneja la actualización de un preapproval */
    private void handlePreapprovalUpdated(
            MercadoPagoPreapproval localPreapproval, Preapproval mpPreapproval) {
        log.info("Preapproval actualizado: {}", localPreapproval.getPreapprovalId());

        // Actualizar estado del preapproval
        if (mpPreapproval.getStatus() != null) {
            PreapprovalStatus status = mapMPPreapprovalStatus(mpPreapproval.getStatus());
            localPreapproval.setStatus(status);
        }
        localPreapproval.setLastModified(LocalDateTime.now());
        masterMercadoPagoPreapprovalRepository.save(localPreapproval);

        // Actualizar estado de la suscripción según el estado del preapproval
        Optional<Subscription> subscriptionOpt =
                slaveSubscriptionRepository.findByMercadoPagoPreapproval(localPreapproval);
        if (subscriptionOpt.isPresent()) {
            Subscription subscription = subscriptionOpt.get();

            // Si el preapproval está autorizado, activar la suscripción
            if (localPreapproval.getStatus() == PreapprovalStatus.AUTHORIZED) {
                subscription.setState(State.ACTIVE);
            } else if (localPreapproval.getStatus() == PreapprovalStatus.CANCELLED
                    || localPreapproval.getStatus() == PreapprovalStatus.REJECTED) {
                subscription.setState(State.CANCELLED);
            } else {
                subscription.setState(State.PENDING);
            }

            subscription.setUpdatedAt(LocalDateTime.now());
            masterSubscriptionRepository.save(subscription);
        }
    }

    /** Guarda un registro de pago pendiente para procesamiento posterior */
    private void savePendingPaymentForLater(String paymentId, String action) {
        try {
            // Verificar si ya existe un registro pendiente para este pago
            Optional<MercadoPagoPayment> existingPaymentOpt =
                    slaveMercadoPagoPaymentRepository.findByPaymentId(paymentId);

            if (existingPaymentOpt.isPresent()) {
                log.warn("Ya existe un registro para el pago pendiente: {}", paymentId);
                return;
            }

            MercadoPagoPreapproval preapproval = null;

            // Intentar obtener el pago desde MercadoPago para extraer el external_reference
            PaymentClient client = new PaymentClient();

            try {
                Payment payment = client.get(Long.valueOf(paymentId));
                String externalReference = payment.getExternalReference();

                if (externalReference != null) {
                    // Buscar preapproval por external_reference
                    Optional<MercadoPagoPreapproval> preapprovalOpt =
                            slaveMercadoPagoPreapprovalRepository.findByExternalReference(
                                    externalReference);

                    if (preapprovalOpt.isPresent()) {
                        preapproval = preapprovalOpt.get();
                        log.info(
                                "Preapproval encontrado para external_reference {}: {}",
                                externalReference,
                                preapproval.getPreapprovalId());
                    }
                }
            } catch (MPApiException e) {
                log.warn(
                        "No se pudo obtener el pago {} para asociarlo a un preapproval: {}",
                        paymentId,
                        e.getMessage());

                // Si no podemos obtener el pago, intentamos encontrar el preapproval más reciente
                try {
                    List<MercadoPagoPreapproval> recentPreapprovals =
                            slaveMercadoPagoPreapprovalRepository
                                    .findTop10ByOrderByLastModifiedDesc();

                    if (!recentPreapprovals.isEmpty()) {
                        preapproval = recentPreapprovals.get(0);
                        log.info(
                                "Usando preapproval más reciente como fallback: {}",
                                preapproval.getPreapprovalId());
                    }
                } catch (Exception ex) {
                    log.warn(
                            "No se pudo encontrar un preapproval de fallback: {}", ex.getMessage());
                }
            }

            // Crear un registro de pago pendiente (ahora preapproval puede ser null)
            MercadoPagoPayment pendingPayment =
                    MercadoPagoPayment.builder()
                            .paymentId(paymentId)
                            .preapproval(
                                    preapproval) // Puede ser null si no encontramos el preapproval
                            .status(PaymentStatus.PENDING)
                            .dateCreated(LocalDateTime.now())
                            .dateLastUpdated(LocalDateTime.now())
                            .description("Pago pendiente de procesamiento")
                            .build();

            masterMercadoPagoPaymentRepository.save(pendingPayment);
            log.info("Pago guardado como pendiente para procesamiento posterior: {}", paymentId);

        } catch (Exception e) {
            log.error("Error guardando pago pendiente {}: {}", paymentId, e.getMessage(), e);
        }
    }

    /** Mapea el status de MercadoPago a nuestro enum */
    private PreapprovalStatus mapMPPreapprovalStatus(String mpStatus) {
        if (mpStatus == null) return PreapprovalStatus.PENDING;
        return switch (mpStatus.toLowerCase()) {
            case "authorized" -> PreapprovalStatus.AUTHORIZED;
            case "pending" -> PreapprovalStatus.PENDING;
            case "cancelled" -> PreapprovalStatus.CANCELLED;
            case "rejected" -> PreapprovalStatus.REJECTED;
            case "paused" -> PreapprovalStatus.PAUSED;
            default -> PreapprovalStatus.PENDING;
        };
    }

    /**
     * Procesa pagos que quedaron pendientes por no estar disponibles en MercadoPago
     * Este método podría ser llamado por una tarea programada
     */
    @Scheduled(fixedDelay = 300000) // Cada 5 minutos
    public void processPendingPayments() {
        log.info("Iniciando procesamiento de pagos pendientes");

        // Buscar pagos pendientes con más de 5 minutos de antigüedad
        LocalDateTime threshold = LocalDateTime.now().minusMinutes(5);
        List<MercadoPagoPayment> pendingPayments = slaveMercadoPagoPaymentRepository
                .findByStatusAndDateCreatedBefore(PaymentStatus.PENDING, threshold);

        if (pendingPayments.isEmpty()) {
            log.info("No hay pagos pendientes para procesar");
            return;
        }

        log.info("Se encontraron {} pagos pendientes para procesar", pendingPayments.size());

        PaymentClient client = new PaymentClient();

        for (MercadoPagoPayment pendingPayment : pendingPayments) {
            try {
                log.info("Intentando procesar pago pendiente: {}", pendingPayment.getPaymentId());

                // Intentar obtener el pago desde MercadoPago
                Payment payment = null;
                try {
                    payment = client.get(Long.valueOf(pendingPayment.getPaymentId()));
                } catch (MPApiException e) {
                    if (e.getApiResponse() != null && e.getApiResponse().getStatusCode() == 404) {
                        log.warn("Pago {} no encontrado en MercadoPago, asumimos rechazado", pendingPayment.getPaymentId());

                        // Marcar el pago como rechazado
                        pendingPayment.setStatus(PaymentStatus.DECLINED);
                        pendingPayment.setStatusDetail("Payment not found in MercadoPago API");
                        pendingPayment.setDateLastUpdated(LocalDateTime.now());
                        masterMercadoPagoPaymentRepository.save(pendingPayment);

                        // Cancelar la suscripción asociada
                        if (pendingPayment.getPreapproval() != null) {
                            Optional<Subscription> subscriptionOpt =
                                    slaveSubscriptionRepository.findByMercadoPagoPreapproval(pendingPayment.getPreapproval());

                            if (subscriptionOpt.isPresent()) {
                                Subscription subscription = subscriptionOpt.get();
                                subscription.setState(State.CANCELLED);
                                subscription.setUpdatedAt(LocalDateTime.now());
                                masterSubscriptionRepository.save(subscription);

                                // También actualizar el preapproval
                                MercadoPagoPreapproval preapproval = pendingPayment.getPreapproval();
                                preapproval.setStatus(PreapprovalStatus.CANCELLED);
                                preapproval.setLastModified(LocalDateTime.now());
                                masterMercadoPagoPreapprovalRepository.save(preapproval);

                                log.info("Suscripción cancelada por pago no encontrado: {}", subscription.getId());
                            }
                        }

                        continue; // Pasar al siguiente pago
                    } else {
                        throw e; // Re-lanzar otros errores
                    }
                }

                // Si encontramos el pago, continuar con el procesamiento normal
                // Si no tenemos preapproval asociado, intentar encontrarlo
                if (pendingPayment.getPreapproval() == null) {
                    // Intentar encontrar por external_reference
                    if (payment.getExternalReference() != null) {
                        Optional<MercadoPagoPreapproval> preapprovalOpt =
                                slaveMercadoPagoPreapprovalRepository.findByExternalReference(payment.getExternalReference());

                        if (preapprovalOpt.isPresent()) {
                            pendingPayment.setPreapproval(preapprovalOpt.get());
                            log.info("Preapproval encontrado para pago {}: {}",
                                    pendingPayment.getPaymentId(), preapprovalOpt.get().getPreapprovalId());
                        }
                    }

                    // Si aún no tenemos preapproval, intentar con el más reciente
                    if (pendingPayment.getPreapproval() == null) {
                        List<MercadoPagoPreapproval> recentPreapprovals =
                                slaveMercadoPagoPreapprovalRepository.findTop10ByOrderByLastModifiedDesc();

                        if (!recentPreapprovals.isEmpty()) {
                            pendingPayment.setPreapproval(recentPreapprovals.get(0));
                            log.info("Usando preapproval más reciente para pago {}: {}",
                                    pendingPayment.getPaymentId(), recentPreapprovals.get(0).getPreapprovalId());
                        }
                    }
                }

                // Actualizar el pago con la información obtenida
                updatePaymentFromMP(pendingPayment, payment);
                masterMercadoPagoPaymentRepository.save(pendingPayment);

                // Procesar según el estado del pago
                if (pendingPayment.getStatus() == PaymentStatus.APPROVED) {
                    handlePaymentApproved(pendingPayment);

                    // Si el pago está aprobado, activar la suscripción asociada
                    if (pendingPayment.getPreapproval() != null) {
                        Optional<Subscription> subscriptionOpt =
                                slaveSubscriptionRepository.findByMercadoPagoPreapproval(pendingPayment.getPreapproval());

                        if (subscriptionOpt.isPresent()) {
                            Subscription subscription = subscriptionOpt.get();
                            subscription.setState(State.ACTIVE);
                            subscription.setUpdatedAt(LocalDateTime.now());

                            // Extender la fecha de expiración
                            LocalDateTime currentExpiration = subscription.getExpirationDate();
                            LocalDateTime newExpiration;
                            if (currentExpiration.isBefore(LocalDateTime.now())) {
                                newExpiration = LocalDateTime.now().plusDays(30);
                            } else {
                                newExpiration = currentExpiration.plusDays(30);
                            }
                            subscription.setExpirationDate(newExpiration);

                            masterSubscriptionRepository.save(subscription);

                            // También actualizar el preapproval
                            MercadoPagoPreapproval preapproval = pendingPayment.getPreapproval();
                            preapproval.setStatus(PreapprovalStatus.AUTHORIZED);
                            preapproval.setLastModified(LocalDateTime.now());
                            preapproval.setNextPaymentDate(newExpiration);
                            masterMercadoPagoPreapprovalRepository.save(preapproval);

                            log.info("Suscripción activada por pago aprobado: {}, nueva expiración: {}",
                                    subscription.getId(), newExpiration);
                        }
                    }
                } else if (pendingPayment.getStatus() == PaymentStatus.DECLINED ||
                        pendingPayment.getStatus() == PaymentStatus.ERROR) {
                    handlePaymentFailed(pendingPayment);

                    // Si el pago está rechazado, cancelar la suscripción asociada
                    if (pendingPayment.getPreapproval() != null) {
                        Optional<Subscription> subscriptionOpt =
                                slaveSubscriptionRepository.findByMercadoPagoPreapproval(pendingPayment.getPreapproval());

                        if (subscriptionOpt.isPresent()) {
                            Subscription subscription = subscriptionOpt.get();
                            subscription.setState(State.CANCELLED);
                            subscription.setUpdatedAt(LocalDateTime.now());
                            masterSubscriptionRepository.save(subscription);

                            // También actualizar el preapproval
                            MercadoPagoPreapproval preapproval = pendingPayment.getPreapproval();
                            preapproval.setStatus(PreapprovalStatus.CANCELLED);
                            preapproval.setLastModified(LocalDateTime.now());
                            masterMercadoPagoPreapprovalRepository.save(preapproval);

                            log.info("Suscripción cancelada por pago rechazado: {}", subscription.getId());
                        }
                    }
                }

                log.info("Pago pendiente procesado exitosamente: {}", pendingPayment.getPaymentId());

            } catch (MPApiException e) {
                if (e.getApiResponse() != null && e.getApiResponse().getStatusCode() == 404) {
                    log.warn("Pago {} aún no está disponible en MercadoPago", pendingPayment.getPaymentId());
                    // Mantenemos el pago como pendiente para el siguiente ciclo
                } else {
                    log.error("Error al obtener pago pendiente {}: {}", pendingPayment.getPaymentId(), e.getMessage());
                    // Marcar como error para no reintentar
                    pendingPayment.setStatus(PaymentStatus.ERROR);
                    pendingPayment.setStatusDetail("Error al obtener información de MercadoPago");
                    pendingPayment.setDateLastUpdated(LocalDateTime.now());
                    masterMercadoPagoPaymentRepository.save(pendingPayment);
                }
            } catch (Exception e) {
                log.error("Error procesando pago pendiente {}: {}", pendingPayment.getPaymentId(), e.getMessage(), e);
            }
        }

        log.info("Procesamiento de pagos pendientes finalizado");
    }
}
