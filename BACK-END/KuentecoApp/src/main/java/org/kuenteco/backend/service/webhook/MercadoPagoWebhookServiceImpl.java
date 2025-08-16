package org.kuenteco.backend.service.webhook;

import com.mercadopago.client.payment.PaymentClient;
import com.mercadopago.client.preapproval.PreapprovalClient;
import com.mercadopago.exceptions.MPApiException;
import com.mercadopago.exceptions.MPException;
import com.mercadopago.resources.payment.Payment;
import com.mercadopago.resources.preapproval.Preapproval;
import java.time.LocalDateTime;
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
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class MercadoPagoWebhookServiceImpl implements MercadoPagoWebhookService {

    private final MasterMercadoPagoPreapprovalRepository masterMercadoPagoPreapprovalRepository;
    private final SlaveMercadoPagoPreapprovalRepository slaveMercadoPagoPreapprovalRepository;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final MasterMercadoPagoPaymentRepository masterMercadoPagoPaymentRepository;
    private final SlaveMercadoPagoPaymentRepository slaveMercadoPagoPaymentRepository;
    private final MercadoPagoWebhookValidationService validationService;

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
                case "authorized":
                case "preapproval.authorized":
                    handlePreapprovalAuthorized(localPreapproval, mpPreapproval);
                    break;
                case "pending":
                case "preapproval.pending":
                    handlePreapprovalPending(localPreapproval, mpPreapproval);
                    break;
                case "cancelled":
                case "preapproval.cancelled":
                    handlePreapprovalCancelled(localPreapproval, mpPreapproval);
                    break;
                case "rejected":
                case "preapproval.rejected":
                    handlePreapprovalRejected(localPreapproval, mpPreapproval);
                    break;
                case "paused":
                case "preapproval.paused":
                    handlePreapprovalPaused(localPreapproval, mpPreapproval);
                    break;
                default:
                    log.warn("Acción de preapproval no reconocida: {}", action);
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

            // Obtener información del pago desde MercadoPago
            PaymentClient client = new PaymentClient();
            Payment payment = client.get(Long.valueOf(paymentId));

            // Procesar según el tipo de acción
            switch (action) {
                case "payment.created":
                    handlePaymentCreated(payment);
                    break;
                case "payment.updated":
                    handlePaymentUpdated(payment);
                    break;
                default:
                    log.warn("Acción de payment no reconocida: {}", action);
            }

            log.info("Webhook de payment procesado exitosamente: {}", paymentId);

        } catch (MPException | MPApiException e) {
            log.error(
                    "Error al obtener datos del payment desde MercadoPago: {}", e.getMessage(), e);
        } catch (Exception e) {
            log.error("Error procesando webhook de payment: {}", e.getMessage(), e);
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
        if (localPreapproval.getSubscription() != null) {
            Subscription subscription = localPreapproval.getSubscription();
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
        if (localPreapproval.getSubscription() != null) {
            Subscription subscription = localPreapproval.getSubscription();
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
        if (localPreapproval.getSubscription() != null) {
            Subscription subscription = localPreapproval.getSubscription();
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
        if (localPreapproval.getSubscription() != null) {
            Subscription subscription = localPreapproval.getSubscription();
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
        if (localPreapproval.getSubscription() != null) {
            Subscription subscription = localPreapproval.getSubscription();
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
            // Nota: Asumiendo que el external_reference del pago corresponde al del preapproval
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

        switch (mpStatus.toLowerCase()) {
            case "approved":
                return PaymentStatus.APPROVED;
            case "pending":
            case "in_process":
            case "in_mediation":
                return PaymentStatus.PENDING;
            case "rejected":
            case "cancelled":
                return PaymentStatus.DECLINED;
            case "refunded":
            case "charged_back":
                return PaymentStatus.VOIDED;
            default:
                return PaymentStatus.ERROR;
        }
    }

    private void handlePaymentApproved(MercadoPagoPayment payment) {
        log.info("Procesando pago aprobado: ID={}", payment.getPaymentId());

        try {
            // Obtener la suscripción asociada
            MercadoPagoPreapproval preapproval = payment.getPreapproval();
            if (preapproval != null && preapproval.getSubscription() != null) {
                Subscription subscription = preapproval.getSubscription();

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

        } catch (Exception e) {
            log.error("Error procesando pago aprobado: {}", e.getMessage(), e);
        }
    }

    private void handlePaymentFailed(MercadoPagoPayment payment) {
        log.info("Procesando pago fallido: ID={}", payment.getPaymentId());

        try {
            // Obtener la suscripción asociada
            MercadoPagoPreapproval preapproval = payment.getPreapproval();
            if (preapproval != null && preapproval.getSubscription() != null) {
                Subscription subscription = preapproval.getSubscription();

                // Si la suscripción ya expiró, marcarla como vencida
                if (subscription.getExpirationDate().isBefore(LocalDateTime.now())) {
                    subscription.setState(State.CANCELLED); // No hay estado EXPIRED
                    subscription.setUpdatedAt(LocalDateTime.now());
                    masterSubscriptionRepository.save(subscription);

                    log.info(
                            "Suscripción marcada como vencida por pago fallido: {}",
                            subscription.getId());
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
}
