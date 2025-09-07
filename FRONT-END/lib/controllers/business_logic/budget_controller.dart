import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../core/services/app/budget_service.dart';
import '../../dto/app/budget/budget_dto.dart';
import '../../dto/app/budget/budget_enrollment_dto.dart';
import '../../dto/app/budget/budget_summary_dto.dart';
import '../../dto/app/budget/budget_vs_actual_dto.dart';
import '../../dto/app/budget/new_budget_dto.dart';
import '../../dto/app/budget/update_budget_dto.dart';

class BudgetController extends ChangeNotifier {
  final BudgetService _service;

  BudgetController(this._service);

  List<BudgetDTO> budgets = [];
  List<BudgetVsActualDTO> budgetComparison = [];
  BudgetSummaryDTO? budgetSummary;
  List<BudgetEnrollmentDTO> enrollments = [];

  bool isLoading = false;
  String? errorMessage;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // â Obtener todos los presupuestos
  Future<void> loadBudgets() async {
    _setLoading(true);
    try {
      budgets = await _service.getBudgets();
      errorMessage = null;
    } catch (e) {
      // Si es un error de "no hay datos" o lista vacía, no es realmente un error
      if (e.toString().toLowerCase().contains('empty') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found') ||
          e.toString().contains('404')) {
        budgets = []; // Asegurar lista vacía
        errorMessage = null; // No mostrar como error
      } else {
        errorMessage = 'Error al cargar presupuestos: $e';
      }
    } finally {
      _setLoading(false);
    }
  }

  // â Obtener reportes
  Future<void> loadReports() async {
    _setLoading(true);
    try {
      budgetComparison = await _service.getBudgetComparison();
      budgetSummary = await _service.getBudgetSummary();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error al cargar reportes';
    } finally {
      _setLoading(false);
    }
  }

  // â Obtener enrollments
  Future<void> loadEnrollments() async {
    _setLoading(true);
    try {
      enrollments = await _service.getEnrollments();
      errorMessage = null;
    } catch (e) {
      // Si es un error de "no hay datos" o lista vacía, no es realmente un error
      if (e.toString().toLowerCase().contains('empty') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found') ||
          e.toString().contains('404')) {
        enrollments = []; // Asegurar lista vacía
        errorMessage = null; // No mostrar como error
      } else {
        errorMessage = 'Error al cargar enrolamientos: $e';
      }
    } finally {
      _setLoading(false);
    }
  }

  // â Crear presupuesto
  Future<void> createBudget(NewBudgetDTO dto) async {
    _setLoading(true);
    try {
      final newBudget = await _service.addBudget(dto);
      budgets.add(newBudget);
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al crear presupuesto: $e';
      rethrow; // Relanzar la excepción para que el widget pueda manejarla
    } finally {
      _setLoading(false);
    }
  }

  // â Actualizar presupuesto individual
  Future<void> updateBudget(UpdateBudgetDTO dto) async {
    _setLoading(true);
    try {
      final updated = await _service.updateBudget(dto);
      final index = budgets.indexWhere((b) => b.id == dto.id);
      if (index != -1) {
        budgets[index] = updated;
      } else {
      }
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al actualizar presupuesto: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // â Actualizar múltiples presupuestos
  Future<void> updateBudgetsBatch(List<UpdateBudgetDTO> dtos) async {
    for (final dto in dtos) {
    }
    _setLoading(true);
    try {
      await _service.updateBudgetsBatch(dtos);
      
      // Actualizar los presupuestos en la lista local
      for (final dto in dtos) {
        final index = budgets.indexWhere((b) => b.id == dto.id);
        if (index != -1) {
          // Crear un nuevo BudgetDTO con los datos actualizados
          budgets[index] = BudgetDTO(
            id: dto.id,
            name: dto.name,
            totalBudget: Decimal.parse(dto.totalBudget.toString()),
            remainingBudget: Decimal.parse(dto.remainingBudget.toString()),
            status: budgets[index].status,
            creationDate: budgets[index].creationDate,
          );
        } else {
        }
      }
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al actualizar presupuestos: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // â Eliminar presupuesto
  Future<void> deleteBudget(int id) async {
    _setLoading(true);
    try {
      await _service.deleteBudget(id);
      budgets.removeWhere((b) => b.id == id);
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al eliminar presupuesto: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // â Eliminar múltiples presupuestos
  Future<void> deleteBudgetsBatch(List<int> ids) async {
    _setLoading(true);
    try {
      await _service.deleteBudgetsBatch(ids);
      
      // Eliminar los presupuestos de la lista local
      budgets.removeWhere((budget) => ids.contains(budget.id));
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al eliminar presupuestos: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // â Asignar presupuesto a perfil
  Future<void> enrollProfileToBudget(int profileId, int budgetId) async {
    try {
      await _service.enrollProfileToBudget(profileId, budgetId);
    } catch (e) {
      rethrow;
    }
  }

  // â Eliminar múltiples enrollments
  Future<void> deleteEnrollmentsBatch(List<int> ids) async {
    _setLoading(true);
    try {
      await _service.deleteEnrollmentsBatch(ids);
      
      // Actualizar la lista local de enrollments
      enrollments.removeWhere((enrollment) => ids.contains(enrollment.id));
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al eliminar asignaciones: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // â Asignar múltiples perfiles a presupuestos
  Future<void> enrollProfileToBudgetBatch(List<Map<String, int>> enrollments) async {
    _setLoading(true);
    try {
      await _service.enrollProfileToBudgetBatch(enrollments);
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al asignar presupuestos: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // â Obtener enrollments por usuario
  Future<void> loadUserEnrollments() async {
    _setLoading(true);
    try {
      enrollments = await _service.getEnrollmentsByUser();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error al cargar asignaciones del usuario: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
