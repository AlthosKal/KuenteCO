package org.kuenteco.backend.service.logic.category;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.CategoryEnrollment;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.category.CategoryEnrollmentMapper;
import org.kuenteco.backend.repository.master.MasterCategoryEnrollmentRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryEnrollmentRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryEnrollmentServiceImpl implements CategoryEnrollmentService {
    private final MasterCategoryEnrollmentRepository masterCategoryEnrollmentRepository;
    private final SlaveCategoryEnrollmentRepository slaveCategoryEnrollmentRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final SlaveCategoryRepository slaveCategoryRepository;
    private final CategoryEnrollmentMapper categoryEnrollmentMapper;
    private final SlaveUserRepository slaveUserRepository;

    @Override
    public Object getAllCategoryEnrollments() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Obteniendo las categorías asociadas de: {}", email);
        Profile profile =
                slaveProfileRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new CategoryException("Perfil no encontrado" + email));

        List<CategoryEnrollment> categoryEnrollments =
                slaveCategoryEnrollmentRepository.findByProfile(profile);

        if (categoryEnrollments.isEmpty()) {
            return "No tienes categorías asignadas";
        }
        return categoryEnrollmentMapper.toDTOList(categoryEnrollments);
    }

    @Override
    public CategoryEnrollmentDTO enrollProfileToCategory(Integer profileId, Integer categoryId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new CategoryException("Perfil no encontrado" + email));
        log.info("Asignando una categoría");
        Profile profile =
                slaveProfileRepository
                        .findById(profileId)
                        .orElseThrow(
                                () ->
                                        new CategoryException(
                                                "Perfil no encontrado por el Id: " + profileId));
        Category category =
                slaveCategoryRepository
                        .findById(categoryId)
                        .orElseThrow(
                                () ->
                                        new CategoryException(
                                                "Categoría con encontrada: " + categoryId));

        boolean alreadyEnrolled =
                slaveCategoryEnrollmentRepository.existsByCategoryIdAndProfile_Id(
                        categoryId, profileId);
        if (alreadyEnrolled) {
            throw new CategoryException("El perfil ya tiene asignada esta categoría");
        }

        CategoryEnrollment categoryEnrollment =
                CategoryEnrollment.builder()
                        .user(user)
                        .profile(profile)
                        .category(category)
                        .enrollmentDate(Timestamp.from(Instant.now()))
                        .build();
        masterCategoryEnrollmentRepository.save(categoryEnrollment);

        return categoryEnrollmentMapper.toDTO(categoryEnrollment);
    }

    @Override
    public void removeCategoryEnrollment(Integer id) {
        if (!slaveCategoryEnrollmentRepository.existsById(id)) {
            throw new CategoryException("Asignación no encontrada con el Id: " + id);
        }
        masterCategoryEnrollmentRepository.deleteById(id);
    }
}
