package org.kuenteco.backend.service.logic.category;

import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;

public interface CategoryService {
    Object getCategories();

    void addCategory(NewCategoryDTO dto);

    void updateCategory(CategoryDTO dto);

    void deleteCategory(Integer id);
}
