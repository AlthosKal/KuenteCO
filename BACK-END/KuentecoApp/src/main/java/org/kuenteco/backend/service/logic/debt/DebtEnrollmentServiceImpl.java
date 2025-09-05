package org.kuenteco.backend.service.logic.debt;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.logic.debt.DebtEnrollmentDTO;
import org.kuenteco.backend.dto.logic.debt.DebtEnrollmentProjection;
import org.kuenteco.backend.entity.*;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.exception.exceptions.DebtException;
import org.kuenteco.backend.mapper.logic.debt.DebtEnrollmentMapper;
import org.kuenteco.backend.repository.master.MasterDebtEnrollmentRepository;
import org.kuenteco.backend.repository.slave.*;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class DebtEnrollmentServiceImpl implements DebtEnrollmentService {
    private final MasterDebtEnrollmentRepository masterDebtEnrollmentRepository;
    private final SlaveDebtEnrollmentRepository slaveDebtEnrollmentRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final SlaveDebtRepository slaveDebtRepository;
    private final DebtEnrollmentMapper debtEnrollmentMapper;

    @Override
    public Object getAllDebtEnrollments() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_USER) {
            throw new DebtException("Endpoint solo disponible para perfiles");
        }

        log.info("Obteniendo las deudas asociados de {}", email);
        Profile profile =
                slaveProfileRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Perfil no encontrado" + email));

        List<DebtEnrollment> debtEnrollments = slaveDebtEnrollmentRepository.findByProfile(profile);

        if (debtEnrollments.isEmpty()) {
            return "No tienes deudas asignadas";
        }
        return debtEnrollmentMapper.toDTOList(debtEnrollments);
    }

    @Override
    public Object getBusinessUserDebtEnrollments() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        List<DebtEnrollmentProjection> dto =
                slaveDebtEnrollmentRepository.findDebtEnrollmentsByUserEmail(email);
        if (dto.isEmpty()) {
            return "No tienes Perfiles con Deudas asociadas";
        }
        return dto;
    }

    @Override
    public DebtEnrollmentDTO enrollProfileToDebt(Integer profileId, Integer debtId) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new DebtException("Endpoint solo disponible para usuarios");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new DebtException("Perfil no encontrado" + email));
        log.info("Asignando una deuda");
        Profile profile =
                slaveProfileRepository
                        .findById(profileId)
                        .orElseThrow(
                                () ->
                                        new DebtException(
                                                "Perfil no encontrado por el Id: " + profileId));
        Debt debt =
                slaveDebtRepository
                        .findById(debtId)
                        .orElseThrow(
                                () ->
                                        new DebtException(
                                                "Deuda no encontrado por el Id: " + debtId));

        boolean alreadyEnrolled =
                slaveDebtEnrollmentRepository.existsByDebt_IdAndProfile_Id(debtId, profileId);
        if (alreadyEnrolled) {
            throw new DebtException("El perfil ya tiene asignado esta deuda");
        }

        DebtEnrollment debtEnrollment =
                DebtEnrollment.builder()
                        .user(user)
                        .profile(profile)
                        .debt(debt)
                        .enrollmentDate(LocalDateTime.now())
                        .build();
        masterDebtEnrollmentRepository.save(debtEnrollment);

        return debtEnrollmentMapper.toDTO(debtEnrollment);
    }

    @Override
    public void removeDebtEnrollment(Integer id) {
        if (!slaveDebtEnrollmentRepository.existsById(id)) {
            throw new DebtException("Asignación no encontrada con el Id: " + id);
        }
        masterDebtEnrollmentRepository.deleteById(id);
    }
}
