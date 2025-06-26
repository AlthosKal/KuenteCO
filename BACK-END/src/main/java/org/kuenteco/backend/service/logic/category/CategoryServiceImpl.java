package org.kuenteco.backend.service.logic.category;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.exception.exceptions.CategoryException;
import org.kuenteco.backend.mapper.logic.category.CategoryMapper;
import org.kuenteco.backend.mapper.logic.category.NewCategoryMapper;
import org.kuenteco.backend.repository.master.MasterCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveCategoryRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {
    private final MasterCategoryRepository masterCategoryRepository;
    private final SlaveCategoryRepository slaveCategoryRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final CategoryMapper categoryDTOMapper;
    private final NewCategoryMapper newCategoryMapper;

    @Override
    public Object getCategories() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        log.info("Obteniendo Rubros para: {}", email);

        //Primero buscar por usuario
        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            return getUserCategories(user);
        }

        throw new CategoryException("Usuario no encontrado: " + email);
    }

    @Override
    public void addCategory(NewCategoryDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Category category = newCategoryMapper.toEntity(dto);

        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            log.info("Registrando la categoria para: {}", email);
            category.setUser(user);
            if (dto.getStartDate() == null){
                category.setStartDate(Timestamp.from(Instant.now()));
            }
            masterCategoryRepository.save(category);
        }

        throw new CategoryException("Usuario no encontrado: " + email);
    }

    @Override
    public void updateCategory(CategoryDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();

        Category category = categoryDTOMapper.toEntity(dto);
        User user = slaveUserRepository.findByEmail(email).orElse(null);
        if (user != null) {
            log.info("Actualizando la categoria para: {}", email);
            category.setUser(user);
            masterCategoryRepository.save(category);
        }
        throw new CategoryException("Usuario no encontrado: " + email);
    }

    @Override
    public void deleteCategory(Integer id) {
        if (id == null) {
            throw new CategoryException("Id del rubro no puede ser nulo");
        }

        if (!masterCategoryRepository.existsById(id)) {
            throw new CategoryException("Rubro no encontrado con el ID: " + id);
        }

        masterCategoryRepository.deleteById(id);
        log.info("Categoría eliminada con el ID: {}", id);
    }

    private Object getUserCategories(User user) {
        List<Category> categories = slaveCategoryRepository.findByUser(user);

        if (categories.isEmpty()) {
            return "No tienes rubros registrados";
        }

        return categoryDTOMapper.toDtoList(categories);
    }
}
