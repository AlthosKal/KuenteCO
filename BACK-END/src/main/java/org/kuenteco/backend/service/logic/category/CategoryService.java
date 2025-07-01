package org.kuenteco.backend.service.logic.category;

import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.dto.logic.category.CategoryReportDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.dto.logic.category.TransactionsByCategoryDTO;

import java.util.List;

public interface CategoryService {
    Object getCategories();

    CategoryReportDTO getCategoryReport(Integer categoryId);

    Object getTransactionsByCategory();

    void addCategory(NewCategoryDTO dto);

    void updateCategory(CategoryDTO dto);

    void deleteCategory(Integer id);
}
