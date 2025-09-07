import 'package:flutter/material.dart';

import '../../core/services/app/category_service.dart';
import '../../dto/app/category/batch_enrollment_request_dto.dart';
import '../../dto/app/category/category_dto.dart';
import '../../dto/app/category/category_enrollment_dto.dart';
import '../../dto/app/category/category_enrollment_summary_dto.dart';
import '../../dto/app/category/category_report_dto.dart';
import '../../dto/app/category/new_category_dto.dart';
import '../../dto/app/extra/description_category_extra.dart';
import '../../utils/enum/state_enum.dart' as state_enum;

class CategoryController extends ChangeNotifier {
  final CategoryService _service;

  bool isLoading = false;
  String? errorMessage;

  List<CategoryDTO> categories = [];
  List<CategoryEnrollmentSummaryDTO> summaryReports = [];
  List<CategoryEnrollmentDTO> enrollments = []; // Para perfiles
  List<CategoryEnrollmentSummaryDTO> enrollmentSummaries = []; // Para usuarios de negocios
  List<CategoryEnrollmentDTO> detailedEnrollments = []; // Para gestión detallada de usuarios de negocios
  CategoryReportDTO? currentReport;

  CategoryController(this._service);

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // ð Cargar todas las categorías
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      categories = await _service.getAllCategories();
      _setError(null);
    } catch (e) {
      // Si es un error de "no hay datos" o lista vacía, no es realmente un error
      if (e.toString().toLowerCase().contains('empty') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found') ||
          e.toString().contains('404')) {
        categories = []; // Asegurar lista vacía
        _setError(null); // No mostrar como error
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar resumen de reportes
  Future<void> loadSummaryReports() async {
    _setLoading(true);
    try {
      summaryReports = await _service.getCategoryReportSummary();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar reporte por ID
  Future<void> loadReportById(int id) async {
    _setLoading(true);
    try {
      currentReport = await _service.getCategoryReportById(id);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar inscripciones (para usuarios de negocios - gestionar asignaciones)
  Future<void> loadEnrollments() async {
    _setLoading(true);
    try {
      enrollmentSummaries = await _service.getEnrollmentSummariesByUser();
      
      // Log de las inscripciones para debug
      for (int i = 0; i < enrollmentSummaries.length; i++) {
        final summary = enrollmentSummaries[i];
        print('   Enrollment Summary $i: Category="${summary.categoryName}", Total=${summary.totalEnrollments}, EnrollmentIDs=${summary.categoryEnrollmentIds}');
        print('      EnrolledProfiles count: ${summary.enrolledProfiles?.length ?? 0}');
        if (summary.enrolledProfiles != null) {
          for (int j = 0; j < summary.enrolledProfiles!.length; j++) {
            final profile = summary.enrolledProfiles![j];
            print('         Profile $j: ID=${profile.enrollmentId}, Email=${profile.profileEmail}');
          }
        }
      }
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar inscripciones del perfil autenticado (solo sus asignaciones)
  Future<void> loadProfileEnrollments() async {
    _setLoading(true);
    try {
      enrollments = await _service.getAllEnrollments();
      
      _setError(null);
    } catch (e) {
      
      // Si es un error de "no hay datos" o lista vacía, no es realmente un error
      if (e.toString().toLowerCase().contains('empty') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found') ||
          e.toString().toLowerCase().contains('no tienes categorías') ||
          e.toString().contains('404')) {
        enrollments = []; // Asegurar lista vacía
        _setError(null); // No mostrar como error
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar enrollments detallados para gestión (usuarios de negocios)
  Future<void> loadDetailedEnrollments() async {
    _setLoading(true);
    try {
      
      // Usar el método correcto del servicio para cargar enrollments detallados
      detailedEnrollments = await _service.getDetailedEnrollments();
      
      
      // Log de los enrollments para debug
      for (int i = 0; i < detailedEnrollments.length; i++) {
        final enrollment = detailedEnrollments[i];
        print('   Detailed Enrollment $i: ID=${enrollment.id}, Category="${enrollment.categoryName}", ProfileEmail="${enrollment.profileEmail}", UserEmail="${enrollment.userEmail}"');
      }
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      // En caso de error, mantener la lista vacía para evitar crashes
      detailedEnrollments = [];
    } finally {
      _setLoading(false);
    }
  }

  // ð Agregar categoría
  Future<void> addCategory(NewCategoryDTO dto) async {
    _setError(null); // Limpiar cualquier error previo
    
    try {
      // Crear la categoría en el servidor
      await _service.addCategory(dto);
      
      // Recargar la lista completa desde el servidor
      await loadCategories();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // ð Agregar múltiples categorías (batch)
  Future<void> addCategoriesBatch(List<NewCategoryDTO> dtos) async {
    _setError(null);
    
    try {
      await _service.addCategoriesBatch(dtos);
      
      // Recargar la lista completa desde el servidor
      await loadCategories();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ð Actualizar categoría
  Future<void> updateCategory(CategoryDTO dto) async {
    
    _setError(null); // Limpiar cualquier error previo
    
    try {
      // Actualizar la categoría en el servidor
      await _service.updateCategory(dto);
      
      // Recargar la lista completa desde el servidor
      await loadCategories();
      
      // Verificar si la categoría actualizada está en la lista
      final updatedCategory = categories.firstWhere(
        (cat) => cat.id == dto.id,
        orElse: () => CategoryDTO(
          id: -1, 
          name: '', 
          description: DescriptionCategory(
            assignedBudget: 0.0, 
            state: state_enum.State.PENDING
          ), 
          budgetId: -1, 
          registerDate: DateTime.now()
        ),
      );
      
      if (updatedCategory.id != -1) {
      } else {
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ð Asignar presupuesto a categoría
  Future<void> assignBudgetToCategory(int categoryId, int budgetId) async {
    _setError(null);
    
    try {
      // Buscar la categoría
      final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex == -1) {
        throw Exception('Categoría no encontrada');
      }
      
      final category = categories[categoryIndex];
      
      // Crear nuevo CategoryDTO con budgetId actualizado
      final updatedCategory = CategoryDTO(
        id: category.id,
        budgetId: budgetId,
        name: category.name,
        description: category.description,
        registerDate: category.registerDate,
      );
      
      // Usar el método updateCategory existente
      await updateCategory(updatedCategory);
      
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
  
  // ð Actualizar múltiples categorías (batch)
  Future<void> updateCategoriesBatch(List<CategoryDTO> dtos) async {
    _setError(null);
    
    try {
      await _service.updateCategoriesBatch(dtos);
      
      // Recargar la lista completa desde el servidor
      await loadCategories();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ð Eliminar categoría
  Future<void> deleteCategory(int id) async {
    _setLoading(true);
    try {
      // Eliminar la categoría en el servidor
      await _service.deleteCategory(id);
      
      // Limpiar error antes de recargar
      _setError(null);
      
      // Recargar toda la lista desde el servidor
      await loadCategories();
      
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // ð Eliminar múltiples categorías (batch)
  Future<void> deleteCategoriesBatch(List<int> ids) async {
    _setError(null);
    
    try {
      await _service.deleteCategoriesBatch(ids);
      
      // Recargar la lista completa desde el servidor
      await loadCategories();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ð Asignar categoría a perfil (solo para usuarios Business)
  Future<void> assignCategoryToProfile(int categoryId, int profileId) async {
    
    _setError(null); // Limpiar cualquier error previo
    
    try {
      // Asignar la categoría al perfil en el servidor
      await _service.enrollProfileToCategory(profileId, categoryId);
      
      // Recargar los resúmenes de enrollments para actualizar la UI
      await loadEnrollments();
      
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // ð Eliminar asignación de categoría (enrollment)
  Future<void> deleteEnrollment(int enrollmentId) async {
    _setError(null);
    
    try {
      await _service.deleteEnrollment(enrollmentId);
      
      // Recargar tanto los enrollments detallados como los resúmenes
      await loadDetailedEnrollments();
      await loadEnrollments();
    } catch (e) {
      _setError(e.toString());
      rethrow; // Re-lanzar el error para que la UI pueda manejarlo
    }
  }
  
  // ð Eliminar TODAS las asignaciones de una categoría (solo para usuarios Business)
  Future<void> deleteAllEnrollmentsByCategory(int categoryId) async {
    _setError(null);
    
    try {
      await _service.deleteAllEnrollmentsByCategory(categoryId);
      
      // Recargar los resúmenes de enrollments para actualizar la UI
      await loadEnrollments();
    } catch (e) {
      
      // Alternative approach: Delete enrollments individually
      // This requires getting the detailed enrollments for this category first
      try {
        await loadDetailedEnrollments();
        
        // Find the category name from enrollmentSummaries
        String? categoryName;
        for (final summary in enrollmentSummaries) {
          if (summary.categoryId == categoryId) {
            categoryName = summary.categoryName;
            break;
          }
        }
        
        if (categoryName == null) {
          throw Exception('Category not found in summaries');
        }
        
        // Filter detailed enrollments for this category
        final categoryEnrollments = detailedEnrollments
            .where((enrollment) => 
                enrollment.categoryName == categoryName && 
                enrollment.id != null)
            .toList();
        
        if (categoryEnrollments.isEmpty) {
          await loadEnrollments(); // Still reload to refresh UI
          return;
        }
        
        final enrollmentIds = categoryEnrollments
            .map((e) => e.id!)
            .toList();
        
        await _service.deleteEnrollmentsByIds(enrollmentIds);
        
        // Reload data
        await loadEnrollments();
        
      } catch (alternativeError) {
        _setError('Error al eliminar asignaciones: $alternativeError');
        rethrow;
      }
    }
  }
  
  // ð§ Eliminar asignaciones por IDs usando batch endpoint (método auxiliar)
  Future<void> deleteEnrollmentsByIds(List<int> enrollmentIds) async {
    _setError(null);
    
    try {
      await _service.deleteEnrollmentsBatch(enrollmentIds);
      
      // Recargar tanto los enrollments detallados como los resúmenes
      try {
        await loadDetailedEnrollments();
      } catch (detailedError) {
        // No es crítico si no se pueden recargar los enrollments detallados
      }
      await loadEnrollments();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
  
  // ð Nuevo método: Eliminar asignaciones usando categoryEnrollmentIds del resumen
  Future<void> deleteEnrollmentsByCategorySummary(CategoryEnrollmentSummaryDTO enrollmentSummary) async {
    _setError(null);
    
    try {
      if (enrollmentSummary.categoryEnrollmentIds == null || enrollmentSummary.categoryEnrollmentIds!.isEmpty) {
        throw Exception('No hay IDs de enrollments disponibles para eliminar');
      }
      
      final enrollmentIds = enrollmentSummary.categoryEnrollmentIds!;
      
      await _service.deleteEnrollmentsBatch(enrollmentIds);
      
      // Recargar los resúmenes de enrollments para actualizar la UI
      await loadEnrollments();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
  
  // ð Asignar múltiples perfiles a categorías (NUEVO)
  Future<List<CategoryEnrollmentDTO>> enrollProfilesToCategoriesBatch(List<BatchEnrollmentRequestDTO> enrollments) async {
    _setError(null);
    
    try {
      final results = await _service.enrollProfilesToCategoriesBatch(enrollments);
      
      // Recargar tanto los enrollments detallados como los resúmenes
      await loadDetailedEnrollments();
      await loadEnrollments();
      
      return results;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
}
