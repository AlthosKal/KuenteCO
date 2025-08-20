import 'package:flutter/material.dart';
import '../core/services/app/category_service.dart';
import '../dto/app/category/category_dto.dart';
import '../dto/app/category/category_enrollment_dto.dart';
import '../dto/app/category/category_enrollment_summary_dto.dart';
import '../dto/app/category/category_report_dto.dart';
import '../dto/app/category/new_category_dto.dart';
import '../dto/app/extra/description_category_extra.dart';
import '../utils/enum/state_enum.dart' as state_enum;

class CategoryController extends ChangeNotifier {
  final CategoryService _service;

  bool isLoading = false;
  String? errorMessage;

  List<CategoryDTO> categories = [];
  List<CategoryEnrollmentSummaryDTO> summaryReports = [];
  List<CategoryEnrollmentDTO> enrollments = [];
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

  // 📌 Cargar inscripciones
  Future<void> loadEnrollments() async {
    _setLoading(true);
    try {
      enrollments = await _service.getAllEnrollments();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar inscripciones del perfil autenticado
  Future<void> loadProfileEnrollments() async {
    _setLoading(true);
    try {
      print('🔄 CategoryController: Loading profile enrollments from server...');
      enrollments = await _service.getAllEnrollments();
      print('✅ CategoryController: Loaded ${enrollments.length} profile enrollments from server');
      
      // Log de todas las inscripciones para debug
      for (int i = 0; i < enrollments.length; i++) {
        print('   Profile Enrollment $i: Category="${enrollments[i].categoryName}", ProfileEmail="${enrollments[i].profileEmail}"');
      }
      
      _setError(null);
    } catch (e) {
      print('❌ CategoryController: Error loading profile enrollments: $e');
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
      
      // Recargar las inscripciones desde el servidor
      await loadProfileEnrollments();
    } catch (e) {
      print('❌ CategoryController: Error deleting enrollment: $e');
      _setError(e.toString());
    }
  }
}
