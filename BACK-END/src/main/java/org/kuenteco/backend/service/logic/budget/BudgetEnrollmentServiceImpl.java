package org.kuenteco.backend.service.logic.budget;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.budget.BudgetEnrollmentDTO;
import org.kuenteco.backend.entity.*;
import org.kuenteco.backend.exception.exceptions.BudgetException;
import org.kuenteco.backend.mapper.logic.budget.BudgetEnrollmentMapper;
import org.kuenteco.backend.repository.master.MasterBudgetEnrollmentRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetEnrollmentRepository;
import org.kuenteco.backend.repository.slave.SlaveBudgetRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class BudgetEnrollmentServiceImpl implements BudgetEnrollmentService {
    private final MasterBudgetEnrollmentRepository masterBudgetEnrollmentRepository;
    private final SlaveBudgetEnrollmentRepository slaveBudgetEnrollmentRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final SlaveBudgetRepository slaveBudgetRepository;
    private final BudgetEnrollmentMapper budgetEnrollmentMapper;

    @Override
    public Object getAllBudgetEnrollments() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Obteniendo los presupuestos asociados de {}", email);
        Profile profile =
                slaveProfileRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new BudgetException("Perfil no encontrado" + email));

        List<BudgetEnrollment> budgetEnrollments =
                slaveBudgetEnrollmentRepository.findByProfile(profile);

        if (budgetEnrollments.isEmpty()) {
            return "No tienes presupuesto asignados";
        }
        return budgetEnrollmentMapper.toDTOList(budgetEnrollments);
    }

    @Override
    public BudgetEnrollmentDTO enrollProfileToBudget(Integer profileId, Integer budgetId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new BudgetException("Perfil no encontrado" + email));
        log.info("Asignando un presupuesto");
        Profile profile =
                slaveProfileRepository
                        .findById(profileId)
                        .orElseThrow(
                                () ->
                                        new BudgetException(
                                                "Perfil no encontrado por el Id: " + profileId));
        Budget budget =
                slaveBudgetRepository
                        .findById(budgetId)
                        .orElseThrow(
                                () ->
                                        new BudgetException(
                                                "Presupuesto no encontrado: " + budgetId));

        boolean alreadyEnrolled =
                slaveBudgetEnrollmentRepository.existsByBudget_IdAndProfile_Id(budgetId, profileId);
        if (alreadyEnrolled) {
            throw new BudgetException("El perfil ya tiene asignado este presupuesto");
        }

        BudgetEnrollment budgetEnrollment =
                BudgetEnrollment.builder()
                        .user(user)
                        .profile(profile)
                        .budget(budget)
                        .enrollmentDate(Timestamp.from(Instant.now()))
                        .build();
        masterBudgetEnrollmentRepository.save(budgetEnrollment);

        return budgetEnrollmentMapper.toDTO(budgetEnrollment);
    }

    @Override
    public void removeBudgetEnrollment(Integer id) {
        if (!slaveBudgetEnrollmentRepository.existsById(id)) {
            throw new BudgetException("Asignación no encontrada con el Id: " + id);
        }
        masterBudgetEnrollmentRepository.deleteById(id);
    }
}
