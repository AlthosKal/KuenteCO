package org.kuenteco.backend.service.subscription;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.subscription.AddSubscriptionDTO;
import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.dto.subscription.UpdateSubscriptionDTO;
import org.kuenteco.backend.entity.Account;
import org.kuenteco.backend.entity.PaySubscription;
import org.kuenteco.backend.entity.PaymentHistory;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.extra.DescriptionPaymentHistory;
import org.kuenteco.backend.entity.extra.PayMethodInfo;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.exception.exceptions.AccountException;
import org.kuenteco.backend.mapper.SubscriptionDetailMapper;
import org.kuenteco.backend.repository.master.MasterAccountRepository;
import org.kuenteco.backend.repository.master.MasterPaySubscriptionRepository;
import org.kuenteco.backend.repository.master.MasterPaymentHistoryRepository;
import org.kuenteco.backend.repository.master.MasterSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlavePaySubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveSubscriptionRepository;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Calendar;

@Service
@RequiredArgsConstructor
public class SubscriptionServiceImpl implements SubscriptionService {
    // Mappers
    private final SubscriptionDetailMapper subscriptionDetailMapper;
    // Repositorios maestros
    private final MasterAccountRepository masterAccountRepository;
    private final MasterSubscriptionRepository masterSubscriptionRepository;
    private final MasterPaySubscriptionRepository masterPaySubscriptionRepository;
    private final MasterPaymentHistoryRepository masterPaymentHistoryRepository;
    // Repositorios esclavos
    private final SlaveSubscriptionRepository slaveSubscriptionRepository;
    private final SlavePaySubscriptionRepository slavePaySubscriptionRepository;

    @Override
    public SubscriptionDetailDTO getSubscriptions(Integer subscriptionId) {
        // Obtener la suscripción de la base de datos
        Subscription subscription = slaveSubscriptionRepository.findById(subscriptionId).orElseThrow(
                () -> new EntityNotFoundException("Subscripción no encontrada con el id: " + subscriptionId));

        // Obtener el pago relacionado (puede ser null si no existe)
        PaySubscription paySubscription = slavePaySubscriptionRepository.findBySubscriptionId(subscriptionId)
                .orElse(null);

        // Mapear a DTO
        return subscriptionDetailMapper.toDto(subscription, paySubscription);
    }

    @Override
    public void addSubscription(AddSubscriptionDTO addSubscriptionDTO, Integer accountId) throws IOException {
        // Obtener la cuenta del usuario actual
        Account account = masterAccountRepository.findById(accountId)
                .orElseThrow(() -> new EntityNotFoundException("Cuenta no encontrada con el id: " + accountId));

        // 1. Crear la nueva suscripción
        Subscription subscription = new Subscription();
        subscription.setAccount(account);
        subscription.setType(addSubscriptionDTO.getType());

        // Establecer fechas de inicio y expiración
        Timestamp now = new Timestamp(System.currentTimeMillis());
        subscription.setStartDate(now);

        // Calcular fecha de expiración (un mes)
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(now.getTime());
        calendar.add(Calendar.MONTH, 1);
        Timestamp expirationDate = new Timestamp(calendar.getTimeInMillis());
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
    public void updateSubscription(UpdateSubscriptionDTO updateSubscriptionDTO, Integer subscriptionId,
            Integer accountId) throws IOException {
        // Validar entrada
        if (updateSubscriptionDTO == null) {
            throw new IllegalArgumentException("Campos requeridos, no pueden ser nulos");
        }
        if (subscriptionId == null) {
            throw new IllegalArgumentException("identificador de la subscripción no puede ser nulo");
        }

        // Obtener la suscripción de la base de datos
        Subscription subscription = masterSubscriptionRepository.findById(subscriptionId).orElseThrow(
                () -> new EntityNotFoundException("Subscripción no encotrada con el id: " + subscriptionId));

        // Validar que la suscripción esté activa
        if (subscription.getState() != State.ACTIVE) {
            throw new IllegalStateException("No pueds acualizar la subscripcion de una cuenta no activa");
        }

        // Obtener el pago relacionado (si existe)
        PaySubscription paySubscription = null;
        try {
            Integer paySubscriptionId = getCurrentPaySubscriptionId(accountId);
            paySubscription = masterPaySubscriptionRepository.findById(paySubscriptionId).orElse(null);
        } catch (AccountException e) {
            // No hay pago asociado, continuamos sin él
        }

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

    private void registerSubscriptionChange(Subscription subscription, PaySubscription paySubscription,
            SubscriptionType previousType) {
        if (paySubscription != null) {
            PaymentHistory history = new PaymentHistory();
            history.setPaySubscription(paySubscription);

            DescriptionPaymentHistory details = new DescriptionPaymentHistory();
            details.setTypeSubscription("Cambio de " + previousType + " a " + subscription.getType());
            details.setPaymentMethod(
                    paySubscription.getPayMethod() != null ? paySubscription.getPayMethod().toString() : "N/A");
            details.setAmount(paySubscription.getAmount());
            details.setDate(new Timestamp(System.currentTimeMillis()).toString());

            history.setDetails(details);
            masterPaymentHistoryRepository.save(history);
        }
    }

    private Integer getCurrentPaySubscriptionId(Integer masterAccountId) {
        // Obtener la suscripción activa del usuario
        Subscription activeSubscription = masterSubscriptionRepository
                .findByAccount_IdAndState(masterAccountId, State.ACTIVE).orElseThrow(() -> new AccountException(
                        "No active subscription found for account with id: " + masterAccountId));

        // Obtener el pago relacionado
        return masterPaySubscriptionRepository.findBySubscriptionId(activeSubscription.getId())
                .map(PaySubscription::getId).orElseThrow(() -> new AccountException(
                        "No payment found for active subscription with id: " + activeSubscription.getId()));
    }

    @Override
    public void cancelSubscription(Subscription subscription) throws IOException {
        masterSubscriptionRepository.delete(subscription);
    }
}
