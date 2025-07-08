package org.kuenteco.backend.service.subscription;

import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.subscription.response.PaymentHistoryResponseDTO;
import org.kuenteco.backend.entity.MercadoPagoPayment;
import org.kuenteco.backend.entity.MercadoPagoPreapproval;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.exception.exceptions.SubscriptionMercadoPagoException;
import org.kuenteco.backend.mapper.subscription.MercadoPagoPaymentMapper;
import org.kuenteco.backend.repository.slave.SlaveMercadoPagoPaymentRepository;
import org.kuenteco.backend.repository.slave.SlaveMercadoPagoPreapprovalRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class MercadoPagoPaymentServiceImpl implements MercadoPagoPaymentService {

    private final SlaveMercadoPagoPaymentRepository slaveMercadoPagoPaymentRepository;
    private final SlaveMercadoPagoPreapprovalRepository slaveMercadoPagoPreapprovalRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final MercadoPagoPaymentMapper paymentMapper;

    @Override
    public List<PaymentHistoryResponseDTO> getPaymentHistory(
            String preapprovalId, String userEmail) {
        log.info(
                "Obteniendo historial de pagos para preapproval: {}, usuario: {}",
                preapprovalId,
                userEmail);

        // Validar que el usuario existe
        User user =
                slaveUserRepository
                        .findByEmail(userEmail)
                        .orElseThrow(
                                () ->
                                        new SubscriptionMercadoPagoException(
                                                "Usuario no encontrado"));

        // Buscar preapproval
        MercadoPagoPreapproval preapproval =
                slaveMercadoPagoPreapprovalRepository
                        .findByPreapprovalId(preapprovalId)
                        .orElseThrow(
                                () ->
                                        new SubscriptionMercadoPagoException(
                                                "Preapproval no encontrado"));

        // Verificar que el preapproval pertenece al usuario
        if (!preapproval.getUser().getId().equals(user.getId())) {
            throw new SubscriptionMercadoPagoException(
                    "No tiene permisos para acceder a este historial de pagos");
        }

        // Obtener historial de pagos
        List<MercadoPagoPayment> payments =
                slaveMercadoPagoPaymentRepository.findByPreapprovalOrderByDateCreatedDesc(
                        preapproval);

        log.info("Se encontraron {} pagos para el preapproval: {}", payments.size(), preapprovalId);

        return paymentMapper.toPaymentHistoryResponseList(payments);
    }
}
