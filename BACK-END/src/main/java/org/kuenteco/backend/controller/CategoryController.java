package org.kuenteco.backend.controller;

import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.businesslogic.CategoryDTO;
import org.kuenteco.backend.dto.businesslogic.CategoryRequestDTO;
import org.kuenteco.backend.dto.businesslogic.CategoryResponseDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.mapper.CategoryMapper;
import org.kuenteco.backend.service.businesslogic.category.CategoryService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/v1/category")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;
    private final CategoryMapper categoryMapper;

    @PostMapping
    public ResponseEntity<CategoryResponseDTO> createCategory(@RequestBody CategoryRequestDTO requestDTO) {
        Category createdCategory = categoryService.createCategory(requestDTO.getAccountId(), requestDTO.getAssetId(),
                requestDTO.getName(), requestDTO.getDescription(), requestDTO.getAssignedBudget(),
                requestDTO.getStartDate(), requestDTO.getFinishDate());

        return new ResponseEntity<>(categoryMapper.toResponseDTO(createdCategory), HttpStatus.CREATED);
    }

    @PutMapping("/{categoryId}")
    public ResponseEntity<CategoryResponseDTO> updateCategory(@PathVariable Integer categoryId,
            @RequestBody CategoryRequestDTO requestDTO) {

        Category updatedCategory = categoryService.updateCategory(categoryId, requestDTO.getName(),
                requestDTO.getDescription(), requestDTO.getAssignedBudget(), requestDTO.getStartDate(),
                requestDTO.getFinishDate(), State.valueOf(requestDTO.getState().toString()));

        return ResponseEntity.ok(categoryMapper.toResponseDTO(updatedCategory));
    }

    @GetMapping("/{categoryId}")
    public ResponseEntity<CategoryResponseDTO> getCategoryById(@PathVariable Integer categoryId) {
        return categoryService.getCategoryById(categoryId)
                .map(category -> ResponseEntity.ok(categoryMapper.toResponseDTO(category)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/account/{accountId}")
    public ResponseEntity<List<CategoryResponseDTO>> getCategoriesByAccountId(@PathVariable Integer accountId) {
        List<Category> categories = categoryService.getCategoriesByAccountId(accountId);
        List<CategoryResponseDTO> responseDTOs = categories.stream().map(categoryMapper::toResponseDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responseDTOs);
    }

    @PutMapping("/{categoryId}/assign-budget")
    public ResponseEntity<CategoryResponseDTO> assignBudgetToCategory(@PathVariable Integer categoryId,
            @RequestBody Map<String, Object> request) {
        BigDecimal amount = new BigDecimal(request.get("amount").toString());

        Category updatedCategory = categoryService.assignBudgetToCategory(categoryId, amount);
        return ResponseEntity.ok(categoryMapper.toResponseDTO(updatedCategory));
    }

    @PutMapping("/{categoryId}/change-state")
    public ResponseEntity<CategoryResponseDTO> changeState(@PathVariable Integer categoryId,
            @RequestBody Map<String, Object> request) {
        State state = State.valueOf((String) request.get("state"));

        Category updatedCategory = categoryService.changeState(categoryId, state);
        return ResponseEntity.ok(categoryMapper.toResponseDTO(updatedCategory));
    }

    @GetMapping("/{categoryId}/statistics")
    public ResponseEntity<CategoryDTO> getCategoryStatistics(@PathVariable Integer categoryId) {
        CategoryDTO statistics = categoryService.getCategoryStatistics(categoryId);
        return ResponseEntity.ok(statistics);
    }
}