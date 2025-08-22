package org.kuenteco.backend.service.logic.category;

import org.kuenteco.backend.dto.logic.category.CategoryReportDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.dto.logic.category.UpdateCategoryDTO;

public interface CategoryService {
    Object getCategories();

    CategoryReportDTO getCategoryReport(Integer categoryId);

    Object getTransactionsByCategory();

    void addCategory(NewCategoryDTO dto);

    void updateCategory(UpdateCategoryDTO dto);

    void deleteCategory(Integer id);
}
