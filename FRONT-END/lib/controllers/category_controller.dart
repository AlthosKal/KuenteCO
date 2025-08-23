import 'package:flutter/material.dart';
import '../core/services/app/category_service.dart';
import '../dto/app/category/category_dto.dart';
import '../dto/app/category/category_enrollment_dto.dart';
import '../dto/app/category/category_enrollment_summary_dto.dart';
import '../dto/app/category/category_report_dto.dart';
import '../dto/app/category/new_category_dto.dart';
import '../dto/app/category/batch_enrollment_request_dto.dart';
import '../dto/app/extra/description_category_extra.dart';
import '../utils/enum/state_enum.dart' as state_enum;

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

  // 📌 Cargar todas las categorías
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      print('🔄 CategoryController: Loading categories from server...');
      categories = await _service.getAllCategories();
      print('✅ CategoryController: Loaded ${categories.length} categories from server');
      
      // Log de todas las categorías para debug
      for (int i = 0; i < categories.length; i++) {
        print('   Category $i: ID=${categories[i].id}, Name="${categories[i].name}", State=${categories[i].description.state.name}');
      }
      
      _setError(null);
    } catch (e) {
      print('❌ CategoryController: Error loading categories: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar resumen de reportes
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

  // 📌 Cargar reporte por ID
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

  // 📌 Cargar inscripciones (para usuarios de negocios - gestionar asignaciones)
  Future<void> loadEnrollments() async {
    _setLoading(true);
    try {
      print('🔄 CategoryController: Loading enrollment summaries for business user management...');
      enrollmentSummaries = await _service.getEnrollmentSummariesByUser();
      print('✅ CategoryController: Loaded ${enrollmentSummaries.length} enrollment summaries for business user');
      
      // Log de las inscripciones para debug
      for (int i = 0; i < enrollmentSummaries.length; i++) {
        print('   Enrollment Summary $i: Category="${enrollmentSummaries[i].categoryName}", EnrollmentIDs=${enrollmentSummaries[i].categoryEnrollmentIds}');
      }
      
      _setError(null);
    } catch (e) {
      print('❌ CategoryController: Error loading enrollment summaries for business user: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar inscripciones del perfil autenticado (solo sus asignaciones)
  Future<void> loadProfileEnrollments() async {
    _setLoading(true);
    try {
      print('🔄 CategoryController: Loading profile enrollments from server...');
      enrollments = await _service.getAllEnrollments();
      print('✅ CategoryController: Loaded ${enrollments.length} profile enrollments from server');
      
      // Log de todas las inscripciones para debug
      for (int i = 0; i < enrollments.length; i++) {
        print('   Profile Enrollment $i: ID=${enrollments[i].id}, Category="${enrollments[i].categoryName}", ProfileEmail="${enrollments[i].profileEmail}", UserEmail="${enrollments[i].userEmail}"');
      }
      
      _setError(null);
    } catch (e) {
      print('❌ CategoryController: Error loading profile enrollments: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar enrollments detallados para gestión (usuarios de negocios)
  // NOTA: El endpoint /category/enroll está restringido solo para perfiles.
  // Para usuarios business, necesitamos usar una estrategia diferente
  Future<void> loadDetailedEnrollments() async {
    _setLoading(true);
    try {
      print('🔄 CategoryController: Loading detailed enrollments for business user management...');
      
      // Estrategia alternativa: usar el endpoint de resumen de enrollments por usuario
      // que sí funciona para usuarios business, pero no nos da los detalles individuales
      await loadEnrollments();
      
      // Crear una lista vacía de detailed enrollments ya que no tenemos acceso
      // al endpoint que nos daría los enrollments individuales
      detailedEnrollments = [];
      
      print('⚠️ CategoryController: Detailed enrollments endpoint not available for business users');
      print('📌 CategoryController: Using enrollment summaries instead. Total summaries: ${enrollmentSummaries.length}');
      
      _setError(null);
    } catch (e) {
      print('❌ CategoryController: Error loading detailed enrollments: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Agregar categoría
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
  
  // 📌 Agregar múltiples categorías (batch)
  Future<void> addCategoriesBatch(List<NewCategoryDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 CategoryController: Creating ${dtos.length} categories in batch...');
      await _service.addCategoriesBatch(dtos);
      print('✅ CategoryController: Batch creation completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadCategories();
    } catch (e) {
      print('❌ CategoryController: Error in batch creation: $e');
      _setError(e.toString());
    }
  }

  // 📌 Actualizar categoría
  Future<void> updateCategory(CategoryDTO dto) async {
    print('🔄 CategoryController: Starting update for category ID: ${dto.id}');
    print('🔄 CategoryController: Category data: ${dto.toJson()}');
    
    _setError(null); // Limpiar cualquier error previo
    
    try {
      // Actualizar la categoría en el servidor
      print('🔄 CategoryController: Calling service.updateCategory...');
      await _service.updateCategory(dto);
      print('✅ CategoryController: Service call completed successfully');
      
      // Recargar la lista completa desde el servidor
      print('🔄 CategoryController: Reloading categories from server...');
      await loadCategories();
      print('✅ CategoryController: Categories reloaded. Total categories: ${categories.length}');
      
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
        print('✅ CategoryController: Updated category found in list: ${updatedCategory.toJson()}');
      } else {
        print('❌ CategoryController: Updated category NOT found in reloaded list!');
      }
    } catch (e) {
      print('❌ CategoryController: Error during update: $e');
      _setError(e.toString());
    }
  }
  
  // 📌 Actualizar múltiples categorías (batch)
  Future<void> updateCategoriesBatch(List<CategoryDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 CategoryController: Updating ${dtos.length} categories in batch...');
      await _service.updateCategoriesBatch(dtos);
      print('✅ CategoryController: Batch update completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadCategories();
    } catch (e) {
      print('❌ CategoryController: Error in batch update: $e');
      _setError(e.toString());
    }
  }

  // 📌 Eliminar categoría
  Future<void> deleteCategory(int id) async {
    _setLoading(true);
    try {
      // Eliminar la categoría en el servidor
      await _service.deleteCategory(id);
      
      // Recargar toda la lista desde el servidor para asegurar consistencia
      categories = await _service.getAllCategories();
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // 📌 Eliminar múltiples categorías (batch)
  Future<void> deleteCategoriesBatch(List<int> ids) async {
    _setError(null);
    
    try {
      print('📌 CategoryController: Deleting ${ids.length} categories in batch...');
      await _service.deleteCategoriesBatch(ids);
      print('✅ CategoryController: Batch deletion completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadCategories();
    } catch (e) {
      print('❌ CategoryController: Error in batch deletion: $e');
      _setError(e.toString());
    }
  }

  // 📌 Asignar categoría a perfil (solo para usuarios Business)
  Future<void> assignCategoryToProfile(int categoryId, int profileId) async {
    print('👥 CategoryController: Assigning category $categoryId to profile $profileId');
    
    _setError(null); // Limpiar cualquier error previo
    
    try {
      // Asignar la categoría al perfil en el servidor
      print('👥 CategoryController: Calling service.enrollProfileToCategory...');
      await _service.enrollProfileToCategory(profileId, categoryId);
      print('✅ CategoryController: Category assigned successfully');
      
      // Recargar los resúmenes de enrollments para actualizar la UI
      print('🔄 CategoryController: Reloading enrollment summaries after assignment...');
      await loadEnrollments();
      print('✅ CategoryController: Enrollment summaries reloaded');
      
    } catch (e) {
      print('❌ CategoryController: Error assigning category: $e');
      _setError(e.toString());
    }
  }
  
  // 📌 Eliminar asignación de categoría (enrollment)
  Future<void> deleteEnrollment(int enrollmentId) async {
    _setError(null);
    
    try {
      print('📌 CategoryController: Deleting enrollment with ID: $enrollmentId');
      await _service.deleteEnrollment(enrollmentId);
      print('✅ CategoryController: Enrollment deleted successfully');
      
      // Recargar tanto los enrollments detallados como los resúmenes
      await loadDetailedEnrollments();
      await loadEnrollments();
    } catch (e) {
      print('❌ CategoryController: Error deleting enrollment: $e');
      _setError(e.toString());
      rethrow; // Re-lanzar el error para que la UI pueda manejarlo
    }
  }
  
  // 📌 Eliminar TODAS las asignaciones de una categoría (solo para usuarios Business)
  Future<void> deleteAllEnrollmentsByCategory(int categoryId) async {
    _setError(null);
    
    try {
      print('📌 CategoryController: Deleting ALL enrollments for category ID: $categoryId');
      await _service.deleteAllEnrollmentsByCategory(categoryId);
      print('✅ CategoryController: All enrollments for category deleted successfully');
      
      // Recargar los resúmenes de enrollments para actualizar la UI
      await loadEnrollments();
    } catch (e) {
      print('❌ CategoryController: Bulk delete failed: $e');
      print('📌 CategoryController: Attempting alternative approach...');
      
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
          print('📌 CategoryController: No detailed enrollments found for category');
          await loadEnrollments(); // Still reload to refresh UI
          return;
        }
        
        final enrollmentIds = categoryEnrollments
            .map((e) => e.id!)
            .toList();
        
        print('📌 CategoryController: Attempting to delete ${enrollmentIds.length} enrollments individually');
        await _service.deleteEnrollmentsByIds(enrollmentIds);
        print('✅ CategoryController: All enrollments deleted successfully via alternative method');
        
        // Reload data
        await loadEnrollments();
        
      } catch (alternativeError) {
        print('❌ CategoryController: Alternative approach also failed: $alternativeError');
        _setError('Error al eliminar asignaciones: $alternativeError');
        rethrow;
      }
    }
  }
  
  // 🔧 Eliminar asignaciones por IDs usando batch endpoint (método auxiliar)
  Future<void> deleteEnrollmentsByIds(List<int> enrollmentIds) async {
    _setError(null);
    
    try {
      print('📌 CategoryController: Deleting ${enrollmentIds.length} enrollments by IDs using batch endpoint');
      await _service.deleteEnrollmentsBatch(enrollmentIds);
      print('✅ CategoryController: All enrollments deleted successfully by batch IDs');
      
      // Recargar tanto los enrollments detallados como los resúmenes
      try {
        await loadDetailedEnrollments();
      } catch (detailedError) {
        print('⚠️ CategoryController: Could not reload detailed enrollments: $detailedError');
        // No es crítico si no se pueden recargar los enrollments detallados
      }
      await loadEnrollments();
    } catch (e) {
      print('❌ CategoryController: Error deleting enrollments by batch IDs: $e');
      _setError(e.toString());
      rethrow;
    }
  }
  
  // 🆕 Nuevo método: Eliminar asignaciones usando categoryEnrollmentIds del resumen
  Future<void> deleteEnrollmentsByCategorySummary(CategoryEnrollmentSummaryDTO enrollmentSummary) async {
    _setError(null);
    
    try {
      if (enrollmentSummary.categoryEnrollmentIds == null || enrollmentSummary.categoryEnrollmentIds!.isEmpty) {
        throw Exception('No hay IDs de enrollments disponibles para eliminar');
      }
      
      final enrollmentIds = enrollmentSummary.categoryEnrollmentIds!;
      print('📌 CategoryController: Deleting ${enrollmentIds.length} enrollments for category "${enrollmentSummary.categoryName}"');
      print('📌 CategoryController: Enrollment IDs to delete: $enrollmentIds');
      
      await _service.deleteEnrollmentsBatch(enrollmentIds);
      print('✅ CategoryController: All enrollments for category deleted successfully using batch endpoint');
      
      // Recargar los resúmenes de enrollments para actualizar la UI
      await loadEnrollments();
    } catch (e) {
      print('❌ CategoryController: Error deleting enrollments by category summary: $e');
      _setError(e.toString());
      rethrow;
    }
  }
  
  // 🆕 Asignar múltiples perfiles a categorías (NUEVO)
  Future<List<CategoryEnrollmentDTO>> enrollProfilesToCategoriesBatch(List<BatchEnrollmentRequestDTO> enrollments) async {
    _setError(null);
    
    try {
      print('📌 CategoryController: Creating ${enrollments.length} enrollments in batch');
      final results = await _service.enrollProfilesToCategoriesBatch(enrollments);
      print('✅ CategoryController: Batch enrollments created successfully');
      
      // Recargar tanto los enrollments detallados como los resúmenes
      await loadDetailedEnrollments();
      await loadEnrollments();
      
      return results;
    } catch (e) {
      print('❌ CategoryController: Error creating batch enrollments: $e');
      _setError(e.toString());
      rethrow;
    }
  }
}
