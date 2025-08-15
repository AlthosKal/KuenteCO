import 'package:flutter/material.dart';
import '../core/services/app/category_service.dart';
import '../dto/app/category/category_dto.dart';
import '../dto/app/category/category_enrollment_dto.dart';
import '../dto/app/category/category_enrollment_summary_dto.dart';
import '../dto/app/category/category_report_dto.dart';
import '../dto/app/category/new_category_dto.dart';

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
      categories = await _service.getAllCategories();
      _setError(null);
    } catch (e) {
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

  // 📌 Agregar categoría
  Future<void> addCategory(NewCategoryDTO dto) async {
    _setLoading(true);
    try {
      final newCategory = await _service.addCategory(dto);
      categories.add(newCategory);
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Actualizar categoría
  Future<void> updateCategory(CategoryDTO dto) async {
    _setLoading(true);
    try {
      final updated = await _service.updateCategory(dto);
      final index = categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        categories[index] = updated;
      }
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Eliminar categoría
  Future<void> deleteCategory(int id) async {
    _setLoading(true);
    try {
      await _service.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
