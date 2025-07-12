package org.kuenteco.backend.controller.logic.category;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.dto.logic.category.CategoryEnrollmentDTO;
import org.kuenteco.backend.dto.logic.category.CategoryReportDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.category.CategoryEnrollmentService;
import org.kuenteco.backend.service.logic.category.CategoryService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("v1/category")
@AllArgsConstructor
public class CategoryController {
    private CategoryService categoryService;
    private CategoryEnrollmentService categoryEnrollmentService;

    @GetMapping
    public ResponseEntity<?> getCategories(HttpServletRequest request,  @RequestParam(required = false) String from,
                                           @RequestParam(required = false) String to, @RequestParam(required = false) String kind) {
        Object result = categoryService.getCategories();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Categorías obtenidas correctamente", result, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/enroll")
    public ResponseEntity<?> getAllCategoryEnrollments(HttpServletRequest request,  @RequestParam(required = false) String from,
                                                       @RequestParam(required = false) String to, @RequestParam(required = false) String kind) {
        Object result = categoryEnrollmentService.getAllCategoryEnrollments();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Categorías obtenidas correctamente", result, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/report/{categoryId}")
    public ResponseEntity<?> getCategoryReport(
            @PathVariable Integer categoryId, HttpServletRequest request,  @RequestParam(required = false) String from,
            @RequestParam(required = false) String to, @RequestParam(required = false) String kind) {
        CategoryReportDTO dto = categoryService.getCategoryReport(categoryId);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Reporte de categoría generado exitosamente", dto, request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/report/summary")
    public ResponseEntity<?> getTransactionsByCategory(HttpServletRequest request,  @RequestParam(required = false) String from,
                                                       @RequestParam(required = false) String to, @RequestParam(required = false) String kind){
        Object result = categoryService.getTransactionsByCategory();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Resumen de transacciones por categoría obtenido correctamente",
                        result,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @GetMapping("/enroll/user")
    public ResponseEntity<?> getBusinessUserCategoryEnrollments(HttpServletRequest request,  @RequestParam(required = false) String from,
                                                                @RequestParam(required = false) String to, @RequestParam(required = false) String kind) {
        Object result = categoryEnrollmentService.getBusinessUserCategoryEnrollments();
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Resumen de transacciones por categoría obtenido correctamente",
                        result,
                        request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/add")
    public ResponseEntity<?> addCategory(
            @Valid @RequestBody NewCategoryDTO dto, HttpServletRequest request) {
        categoryService.addCategory(dto);
        return new ResponseEntity<>(
                ApiResponse.ok("Categoría creada correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/batch/add")
    public ResponseEntity<?> addCategories(
            @Valid @RequestBody List<NewCategoryDTO> dto, HttpServletRequest request) {
        dto.forEach(categoryService::addCategory);
        return new ResponseEntity<>(
                ApiResponse.ok("Categoría creadas correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PatchMapping("/update")
    public ResponseEntity<?> updateCategory(
            @Valid @RequestBody CategoryDTO dto, HttpServletRequest request) {
        categoryService.updateCategory(dto);
        return new ResponseEntity<>(
                ApiResponse.ok("Categoría actualizada correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PutMapping("/batch/update")
    public ResponseEntity<?> updateCategories(
            @Valid @RequestBody List<CategoryDTO> dto, HttpServletRequest request) {
        dto.forEach(categoryService::updateCategory);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        "Categoría actualizadas correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PostMapping("/enroll/add")
    public ResponseEntity<?> enrollProfileToCategory(
            @RequestParam Integer profileId,
            @RequestParam Integer categoryId,
            HttpServletRequest request) {
        CategoryEnrollmentDTO dto =
                categoryEnrollmentService.enrollProfileToCategory(profileId, categoryId);
        return new ResponseEntity<>(
                ApiResponse.ok("Categoría asignada correctamente", dto, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCategory(@PathVariable Integer id, HttpServletRequest request) {
        categoryService.deleteCategory(id);
        return new ResponseEntity<>(
                ApiResponse.ok("Categoría eliminada correctamente", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/batch")
    public ResponseEntity<?> deleteCategories(
            @RequestParam List<Integer> id, HttpServletRequest request) {
        id.forEach(categoryService::deleteCategory);
        return new ResponseEntity<>(
                ApiResponse.ok(
                        String.format("%d Categorías eliminadas correctamente", id.size()),
                        null,
                        request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }

    @DeleteMapping("/enroll/{id}")
    public ResponseEntity<?> removeCategoryEnrollment(
            @PathVariable Integer id, HttpServletRequest request) {
        categoryEnrollmentService.removeCategoryEnrollment(id);
        return new ResponseEntity<>(
                ApiResponse.ok("Asignación eliminada correctamente", null, request.getRequestURI()),
                HttpStatus.NO_CONTENT);
    }
}
