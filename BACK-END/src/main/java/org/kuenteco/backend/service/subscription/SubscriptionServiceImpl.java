package org.kuenteco.backend.service.subscription;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.subscription.AddSubscriptionDTO;
import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.dto.subscription.UpdateSubscriptionDTO;
import org.kuenteco.backend.entity.master.MasterAccount;
import org.kuenteco.backend.entity.master.MasterPaySubscription;
import org.kuenteco.backend.entity.master.MasterPaymentHistory;
import org.kuenteco.backend.entity.master.MasterSubscription;
import org.kuenteco.backend.entity.master.extra.MasterDescriptionPaymentHistory;
import org.kuenteco.backend.entity.master.extra.MasterPayMethodInfo;
import org.kuenteco.backend.entity.slave.SlavePaySubscription;
import org.kuenteco.backend.entity.slave.SlaveSubscription;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.exception.exceptions.AccountException;
import org.kuenteco.backend.mapper.dto.SubscriptionDetailMapper;
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
    //Mappers
    private final SubscriptionDetailMapper subscriptionDetailMapper;
    //Repositorios maestros
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
        SlaveSubscription subscription = slaveSubscriptionRepository.findById(subscriptionId)
                .orElseThrow(() -> new EntityNotFoundException("Subscripción no encontrada con el id: " + subscriptionId));

        // Obtener el pago relacionado (puede ser null si no existe)
        SlavePaySubscription paySubscription = slavePaySubscriptionRepository.findBySlaveSubscriptionId(subscriptionId)
                .orElse(null);

        // Mapear a DTO
        return subscriptionDetailMapper.toDto(subscription, paySubscription);
    }

    @Override
    public void addSubscription(AddSubscriptionDTO addSubscriptionDTO, Integer accountId) throws IOException {
        // Obtener la cuenta del usuario actual
        MasterAccount masterAccount = masterAccountRepository.findById(accountId)
                .orElseThrow(() -> new EntityNotFoundException("Cuenta no encontrada con el id: " + accountId));

        // 1. Crear la nueva suscripción
        MasterSubscription subscription = new MasterSubscription();
        subscription.setMasterAccount(masterAccount);
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
        MasterPaySubscription paySubscription = new MasterPaySubscription();
        paySubscription.setMasterSubscription(subscription);
        paySubscription.setAmount(addSubscriptionDTO.getAmount());
        paySubscription.setPayDate(now);

        // Inicializar el método de pago
        MasterPayMethodInfo payMethodInfo = new MasterPayMethodInfo();
        // Configurar payMethodInfo según sea necesario
        paySubscription.setPayMethod(payMethodInfo);

        // Guardar el pago
        masterPaySubscriptionRepository.save(paySubscription);

        // 3. Crear el historial de pago
        MasterPaymentHistory paymentHistory = new MasterPaymentHistory();
        paymentHistory.setMasterPaySubscription(paySubscription);
        paymentHistory.setDetails(addSubscriptionDTO.getDetails());

        // Guardar el historial de pago
        masterPaymentHistoryRepository.save(paymentHistory);
    }

    @Override
    public void updateSubscription(UpdateSubscriptionDTO updateSubscriptionDTO, Integer subscriptionId, Integer masterAccountId) throws IOException {
        // Validar entrada
        if (updateSubscriptionDTO == null) {
            throw new IllegalArgumentException("Campos requeridos, no pueden ser nulos");
        }
        if (subscriptionId == null) {
            throw new IllegalArgumentException("identificador de la subscripción no puede ser nulo");
        }

        // Obtener la suscripción de la base de datos
        MasterSubscription subscription = masterSubscriptionRepository.findById(subscriptionId)
                .orElseThrow(() -> new EntityNotFoundException("Subscripción no encotrada con el id: " + subscriptionId));

        // Validar que la suscripción esté activa
        if (subscription.getState() != State.ACTIVE) {
            throw new IllegalStateException("No pueds acualizar la subscripcion de una cuenta no activa");
        }

        // Obtener el pago relacionado (si existe)
        MasterPaySubscription paySubscription = null;
        try {
            Integer paySubscriptionId = getCurrentPaySubscriptionId(masterAccountId);
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

    private void registerSubscriptionChange(MasterSubscription subscription,
                                            MasterPaySubscription paySubscription,
                                            SubscriptionType previousType) {
        if (paySubscription != null) {
            MasterPaymentHistory history = new MasterPaymentHistory();
            history.setMasterPaySubscription(paySubscription);

            MasterDescriptionPaymentHistory details = new MasterDescriptionPaymentHistory();
            details.setTypeSubscription("Cambio de " + previousType + " a " + subscription.getType());
            details.setPaymentMethod(paySubscription.getPayMethod() != null ?
                    paySubscription.getPayMethod().toString() : "N/A");
            details.setAmount(paySubscription.getAmount());
            details.setDate(new Timestamp(System.currentTimeMillis()).toString());

            history.setDetails(details);
            masterPaymentHistoryRepository.save(history);
        }
    }

    private Integer getCurrentPaySubscriptionId(Integer masterAccountId) {
        // Obtener la suscripción activa del usuario
        MasterSubscription activeSubscription = masterSubscriptionRepository
                .findByMasterAccount_IdAndState(masterAccountId, State.ACTIVE)
                .orElseThrow(() -> new AccountException(
                        "No active subscription found for account with id: " + masterAccountId));

        // Obtener el pago relacionado
        return masterPaySubscriptionRepository.findByMasterSubscriptionId(activeSubscription.getId())
                .map(MasterPaySubscription::getId)
                .orElseThrow(() -> new AccountException(
                        "No payment found for active subscription with id: " + activeSubscription.getId()));
    }

    @Override
    public void cancelSubscription(MasterSubscription subscription) throws IOException {
        masterSubscriptionRepository.delete(subscription);
    }
}
