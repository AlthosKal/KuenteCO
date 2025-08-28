package org.kuenteco.backend.service.logic.debt;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.logic.debt.DebtDTO;
import org.kuenteco.backend.dto.logic.debt.DebtPaymentDTO;
import org.kuenteco.backend.dto.logic.debt.DebtSummaryDTO;
import org.kuenteco.backend.dto.logic.debt.NewDebtDTO;
import org.kuenteco.backend.entity.Debt;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.StateDebt;
import org.kuenteco.backend.exception.exceptions.DebtException;
import org.kuenteco.backend.mapper.logic.debt.DebtDetailMapper;
import org.kuenteco.backend.mapper.logic.debt.DebtsByStateMapper;
import org.kuenteco.backend.mapper.logic.debt.NewDebtMapper;
import org.kuenteco.backend.mapper.logic.debt.UpdateDebtMapper;
import org.kuenteco.backend.repository.master.MasterDebtRepository;
import org.kuenteco.backend.repository.slave.SlaveDebtRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@AllArgsConstructor
public class DebtServiceImpl implements DebtService {

    private final MasterDebtRepository masterDebtRepository;
    private final SlaveDebtRepository slaveDebtRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final DebtDetailMapper debtDetailMapper;
    private final DebtsByStateMapper debtsByStateMapper;
    private final NewDebtMapper newDebtMapper;
    private final UpdateDebtMapper updateDebtMapper;

    @Override
    public Object getDebts() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
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
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        log.info("Buscando deudas por estado para: {}", email);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuarío no encontrado " + email));

        List<Debt> debts = slaveDebtRepository.findByStateAndUser(state, user);
        if (debts.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return debtsByStateMapper.toDtoList(debts);
    }

    @Override
    public Object getOverdueDebts() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        log.info("Buscando deudas atrasadas para: {}", email);

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));

        List<Debt> debt =
                slaveDebtRepository.getDebtsByExpirationDateBeforeAndUser(
                        LocalDateTime.now(), user);
        if (debt.isEmpty()) {
            return "No tienes deudas atrasadas";
        }
        return debtDetailMapper.toDtoList(debt);
    }

    @Override
    public Object getDebtsExpiringInDays(Integer days) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));

        // Calcular la fecha objetivo a partir de hoy + days
        LocalDate today = LocalDate.now();
        LocalDate targetDate = today.plusDays(days);

        LocalDateTime startOfDay = targetDate.atStartOfDay();
        LocalDateTime endOfDay = targetDate.atTime(LocalTime.MAX);

        List<Debt> debts =
                slaveDebtRepository.findByUserAndExpirationDateBetween(user, startOfDay, endOfDay);

        if (debts.isEmpty()) {
            return "No tienes deudas por expirar a la fecha registrada";
        }
        return debtDetailMapper.toDtoList(debts);
    }

    @Override
    public BigDecimal getTotalPendingAmount() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));
        // Aquí se especifica el estado deseado para el cálculo
        BigDecimal total =
                slaveDebtRepository.sumPendingAmountByStateAndUser(StateDebt.ACTIVE, user);

        // Evitar que devuelva null cuando no hay deudas activas, se devuelve BigDecimal.ZERO
        return total != null ? total : BigDecimal.ZERO;
    }

    @Override
    public Object getDebtSummaryReport() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        List<DebtSummaryDTO> dto = slaveDebtRepository.findByUserEmailDebtSummaries(email);
        if (dto.isEmpty()) {
            return "No tienes deudas registradas";
        }
        return dto;
    }

    @Override
    public void addDebt(NewDebtDTO dto) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));

        // Validar fechas
        if (dto.getExpirationDate().isBefore(dto.getStartDate())) {
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
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Usuario no encontrado " + email));
        slaveDebtRepository
                .findById(dto.getId())
                .orElseThrow(() -> new DebtException("No deuda encontrada"));
        Debt debt = updateDebtMapper.toEntity(dto);
        debt.setUser(user);
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
        AuthCredentials credentials = getCredentials();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        if (!slaveDebtRepository.existsById(id)) {
            throw new DebtException("Deuda no encontrada con ID: " + id);
        }
        masterDebtRepository.deleteById(id);
    }

    @Override
    public void updateDebtState(Integer id, StateDebt newState) {
        AuthCredentials credentials = getCredentials();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
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
