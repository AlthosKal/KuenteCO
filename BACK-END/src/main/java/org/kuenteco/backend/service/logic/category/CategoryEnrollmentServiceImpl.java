package org.kuenteco.backend.service.logic.category;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;
import org.kuenteco.backend.entity.CategoryEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.category.CategoryEnrollmentMapper;
import org.kuenteco.backend.repository.master.MasterCategoryEnrollmentRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryEnrollmentRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryEnrollmentServiceImpl implements CategoryEnrollmentService {
    private final MasterCategoryEnrollmentRepository masterCategoryEnrollmentRepository;
    private final SlaveCategoryEnrollmentRepository slaveCategoryEnrollmentRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final SlaveCategoryRepository slaveCategoryRepository;
    private final CategoryEnrollmentMapper categoryEnrollmentMapper;
    @Override
    public Object getAllCategoryEnrollments() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Obteniendo las categorías asociadas de: {}", email);
        Profile profile = slaveProfileRepository.findByEmail(email).orElseThrow(() -> new CategoryException("Perfil no encontrado" + email));

        List<CategoryEnrollment> categoryEnrollments = slaveCategoryEnrollmentRepository.findByProfile(profile);

        if (categoryEnrollments.isEmpty()) {
            return "No tienes categorías asignadas";
        }
        return categoryEnrollmentMapper.toDTOList(categoryEnrollments);
    }

    @Override
    public CategoryEnrollmentDTO enrollProfileToCategory(Integer profileId, Integer categoryId) {
        return null;
    }

    @Override
    public void removeCategoryEnrollment(Integer categoryEnrollmentId) {

    }
}
