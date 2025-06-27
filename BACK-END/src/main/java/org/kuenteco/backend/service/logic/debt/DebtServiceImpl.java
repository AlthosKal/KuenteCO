package org.kuenteco.backend.service.logic.debt;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.debt.DebtDTO;
import org.kuenteco.backend.dto.logic.debt.DebtPaymentDTO;
import org.kuenteco.backend.dto.logic.debt.NewDebtDTO;
import org.kuenteco.backend.entity.Debt;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.StateDebt;
import org.kuenteco.backend.exception.exceptions.DebtException;
import org.kuenteco.backend.mapper.logic.debt.DebtDetailMapper;
import org.kuenteco.backend.mapper.logic.debt.NewDebtMapper;
import org.kuenteco.backend.mapper.logic.debt.UpdateDebtMapper;
import org.kuenteco.backend.mapper.logic.debt.debtsByStateMapper;
import org.kuenteco.backend.repository.master.MasterDebtRepository;
import org.kuenteco.backend.repository.slave.SlaveDebtRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@AllArgsConstructor
public class DebtServiceImpl implements DebtService {

    private final MasterDebtRepository masterDebtRepository;
    private final SlaveDebtRepository slaveDebtRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final DebtDetailMapper debtDetailMapper;
    private final debtsByStateMapper debtsByStateMapper;
    private final NewDebtMapper newDebtMapper;
    private final UpdateDebtMapper updateDebtMapper;

    @Override
    public Object getDebts() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Buscando deudas para: {}", email);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuarío no encontrado " + email));

        log.info("Usuarío encontrado: {}", email);
        return getUserDebts(user);
    }

    @Override
    public Object getDebtsByState(StateDebt state) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        log.info("Buscando deudas por estado para: {}", email);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuarío no encontrado " + email));

        state = slaveDebtRepository.getDebtsByStateAndUser(state, user);
        if (state.describeConstable().isEmpty()) {
            return "No tienes deudas registradas";
        }
        return debtsByStateMapper.toDtoList(state);
    }

    @Override
    public Object getOverdueDebts() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        log.info("Buscando deudas atrasadas para: {}", email);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));

        List<Debt> debt =
                slaveDebtRepository.getDebtsByExpirationDateBeforeAndUser(
                        Timestamp.from(Instant.now()), user);
        if (debt.isEmpty()) {
            return "No tienes deudas atrasadas";
        }
        return debtDetailMapper.toDtoList(debt);
    }

    @Override
    public Object getDebtsExpiringInDays(Integer days) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));

        List<Debt> debts = slaveDebtRepository.findDebtsByExpirationDate_DayAndUser(days, user);
        if (debts.isEmpty()) {
            return "No tienes deudas por expirar a la fecha registrada";
        }
        return debtDetailMapper.toDtoList(debts);
    }

    @Override
    public BigDecimal getTotalPendingAmount() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));
        return slaveDebtRepository.getTotalPendingAmountByUser(user);
    }

    @Transactional
    public void addDebt(NewDebtDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));

        // Validar fechas
        if (dto.getExpirationDate().before(dto.getStartDate())) {
            throw new DebtException(
                    "La fecha de vencimiento no puede ser anterior a la fecha de inicio");
        }

        // Validar que el monto pendiente no sea mayor al total
        if (dto.getPendingAmount().compareTo(dto.getTotalAmount()) > 0) {
            throw new DebtException("El monto pendiente no puede ser mayor al monto total");
        }

        Debt debt = newDebtMapper.toEntity(dto);
        log.info("Registrando deuda para {}", email);
        debt.setUser(user);
        masterDebtRepository.save(debt);
    }

    @Override
    public void updateDebt(DebtDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));
        Debt debt = slaveDebtRepository.findDebtByUser(user);
        updateDebtMapper.toEntity(dto);
        log.info("Actualizando deuda para {}", email);
        masterDebtRepository.save(debt);
    }

    @Override
    public void makePayment(DebtPaymentDTO paymentDTO) {
        Debt debt =
                slaveDebtRepository
                        .findById(paymentDTO.getDebtId())
                        .orElseThrow(
                                () ->
                                        new DebtException(
                                                "Deuda no encontrada con ID: "
                                                        + paymentDTO.getDebtId()));

        if (!debt.getState().equals(StateDebt.ACTIVE)) {
            throw new DebtException("No se puede realizar un pago a una deuda que no está activa");
        }

        if (paymentDTO.getPaymentAmount().compareTo(debt.getPendingAmount()) > 0) {
            throw new DebtException("El monto del pago no puede ser mayor al monto pendiente");
        }

        BigDecimal newPendingAmount =
                debt.getPendingAmount().subtract(paymentDTO.getPaymentAmount());
        debt.setPendingAmount(newPendingAmount);

        // Si se pagó completamente, marcar como pagado
        if (newPendingAmount.compareTo(BigDecimal.ZERO) == 0) {
            debt.setState(StateDebt.PAID);
        }
        masterDebtRepository.save(debt);
    }

    @Override
    public void deleteDebt(Integer id) {
        if (!slaveDebtRepository.existsById(id)) {
            throw new DebtException("Deuda no encontrada con ID: " + id);
        }
        masterDebtRepository.deleteById(id);
    }

    @Override
    public void updateDebtState(Integer id, StateDebt newState) {
        Debt debt =
                slaveDebtRepository
                        .findById(id)
                        .orElseThrow(() -> new DebtException("Deuda no encontrada con ID: " + id));

        debt.setState(newState);
        masterDebtRepository.save(debt);
    }

    private Object getUserDebts(User user) {
        List<Debt> debts = slaveDebtRepository.findByUser(user);

        if (debts.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return debtDetailMapper.toDtoList(debts);
    }
}
