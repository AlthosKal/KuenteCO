package org.kuenteco.backend.service.subscription;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Calendar;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.subscription.AddSubscriptionDTO;
import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.dto.subscription.UpdateSubscriptionDTO;
import org.kuenteco.backend.entity.*;
import org.kuenteco.backend.entity.extra.DescriptionPaymentHistory;
import org.kuenteco.backend.entity.extra.PayMethodInfo;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.exception.exceptions.SubscriptionException;
import org.kuenteco.backend.mapper.SubscriptionDetailMapper;
import org.kuenteco.backend.repository.master.*;
import org.kuenteco.backend.repository.slave.SlavePaySubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SubscriptionServiceImpl implements SubscriptionService {
    // Mappers
    private final SubscriptionDetailMapper subscriptionDetailMapper;
    // Repositorios maestros
    private final MasterUserRepository masterUserRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final MasterPaySubscriptionRepository masterPaySubscriptionRepository;
    private final MasterPaymentHistoryRepository masterPaymentHistoryRepository;
    // Repositorios esclavos
    private final SlaveSubscriptionRepository slaveSubscriptionRepository;
    private final SlavePaySubscriptionRepository slavePaySubscriptionRepository;

    @Override
    public SubscriptionDetailDTO getSubscriptions() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user =
                slaveUserRepository
                        .findByEmail(authentication.getName())
                        .orElseThrow(() -> new SubscriptionException("Usuario no encontrado"));

        // Obtener la suscripción de la base de datos
        Subscription subscription = slaveSubscriptionRepository.findByUser(user);

        // Obtener el pago relacionado (puede ser null si no existe)
        PaySubscription paySubscription =
                slavePaySubscriptionRepository.findBySubscription(subscription);

        // Mapear a DTO
        return subscriptionDetailMapper.toDto(subscription, paySubscription);
    }

    @Override
    public void addSubscription(AddSubscriptionDTO addSubscriptionDTO) {
        // Obtener la cuenta del usuario actual
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user =
                slaveUserRepository
                        .findByEmail(authentication.getName())
                        .orElseThrow(() -> new SubscriptionException("Usuario no encontrado"));

        // 1. Crear la nueva suscripción
        Subscription subscription = new Subscription();
        subscription.setUser(user);
        subscription.setType(addSubscriptionDTO.getType());

        // Establecer fechas de inicio y expiración
        LocalDateTime now = LocalDateTime.now();
        subscription.setStartDate(now);

        // Calcular fecha de expiración (un mes)
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(now.getDayOfMonth());
        calendar.add(Calendar.MONTH, 1);
        LocalDateTime expirationDate = LocalDateTime.now();
        subscription.setExpirationDate(expirationDate);

        // Establecer estado activo
        subscription.setState(State.ACTIVE);

        // Guardar la suscripción
        masterSubscriptionRepository.save(subscription);

        // 2. Crear el registro de pago
        PaySubscription paySubscription = new PaySubscription();
        paySubscription.setSubscription(subscription);
        paySubscription.setAmount(addSubscriptionDTO.getAmount());
        paySubscription.setPayDate(now);

        // Inicializar el método de pago
        PayMethodInfo payMethodInfo = new PayMethodInfo();
        // Configurar payMethodInfo según sea necesario
        paySubscription.setPayMethod(payMethodInfo);

        // Guardar el pago
        masterPaySubscriptionRepository.save(paySubscription);

        // 3. Crear el historial de pago
        PaymentHistory paymentHistory = new PaymentHistory();
        paymentHistory.setPaySubscription(paySubscription);
        paymentHistory.setDetails(addSubscriptionDTO.getDetails());

        // Guardar el historial de pago
        masterPaymentHistoryRepository.save(paymentHistory);
    }

    @Override
    public void updateSubscription(UpdateSubscriptionDTO updateSubscriptionDTO) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user =
                slaveUserRepository
                        .findByEmail(authentication.getName())
                        .orElseThrow(() -> new SubscriptionException("Usuario no encontrado"));
        // Validar entrada
        if (updateSubscriptionDTO == null) {
            throw new IllegalArgumentException("Campos requeridos, no pueden ser nulos");
        }

        // Obtener la suscripción de la base de datos
        Subscription subscription = slaveSubscriptionRepository.findByUser(user);

        // Validar que la suscripción esté activa
        if (subscription.getState() != State.ACTIVE) {
            throw new IllegalStateException(
                    "No puedes actualizar la subscripción de una cuenta no activa");
        }

        // Obtener el pago relacionado (si existe)
        PaySubscription paySubscription =
                slavePaySubscriptionRepository.findBySubscription(subscription);

        // Actualizar los datos de la suscripción
        SubscriptionType previousType = subscription.getType();
        subscription.setType(updateSubscriptionDTO.getType());

        // Si cambió el tipo de suscripción, podemos registrar este cambio
        if (!previousType.equals(updateSubscriptionDTO.getType())) {
            registerSubscriptionChange(subscription, paySubscription, previousType);
        }

        // Guardar los cambios
        masterSubscriptionRepository.save(subscription);
    }

    private void registerSubscriptionChange(
            Subscription subscription,
            PaySubscription paySubscription,
            SubscriptionType previousType) {
        if (paySubscription != null) {
            PaymentHistory history = new PaymentHistory();
            history.setPaySubscription(paySubscription);

            DescriptionPaymentHistory details = new DescriptionPaymentHistory();
            details.setTypeSubscription(
                    "Cambio de " + previousType + " a " + subscription.getType());
            details.setPaymentMethod(
                    paySubscription.getPayMethod() != null
                            ? paySubscription.getPayMethod().toString()
                            : "N/A");
            details.setAmount(paySubscription.getAmount());
            details.setDate(new Timestamp(System.currentTimeMillis()).toString());

            history.setDetails(details);
            masterPaymentHistoryRepository.save(history);
        }
    }

    @Override
    public void cancelSubscription(Subscription subscription) {
        masterSubscriptionRepository.delete(subscription);
    }
}
