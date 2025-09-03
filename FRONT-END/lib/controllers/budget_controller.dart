import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../core/services/app/budget_service.dart';
import '../dto/app/budget/budget_dto.dart';
import '../dto/app/budget/budget_enrollment_dto.dart';
import '../dto/app/budget/budget_summary_dto.dart';
import '../dto/app/budget/budget_vs_actual_dto.dart';
import '../dto/app/budget/new_budget_dto.dart';
import '../dto/app/budget/update_budget_dto.dart';

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

  // ✅ Obtener todos los presupuestos
  Future<void> loadBudgets() async {
    print('BudgetController: loadBudgets() called');
    _setLoading(true);
    try {
      print('BudgetController: Calling service.getBudgets()');
      budgets = await _service.getBudgets();
      print('BudgetController: Received ${budgets.length} budgets');
      errorMessage = null;
    } catch (e) {
      print('BudgetController: Error loading budgets: $e');
      // Si es un error de "no hay datos" o lista vacía, no es realmente un error
      if (e.toString().toLowerCase().contains('empty') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found') ||
          e.toString().contains('404')) {
        print('📝 BudgetController: No budgets found for user - this is normal');
        budgets = []; // Asegurar lista vacía
        errorMessage = null; // No mostrar como error
      } else {
        errorMessage = 'Error al cargar presupuestos: $e';
      }
    } finally {
      _setLoading(false);
      print('BudgetController: loadBudgets() finished, loading: $isLoading');
    }
  }

  // ✅ Obtener reportes
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

  // ✅ Obtener enrollments
  Future<void> loadEnrollments() async {
    _setLoading(true);
    try {
      enrollments = await _service.getEnrollments();
      errorMessage = null;
    } catch (e) {
      print('BudgetController: Error loading enrollments: $e');
      // Si es un error de "no hay datos" o lista vacía, no es realmente un error
      if (e.toString().toLowerCase().contains('empty') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found') ||
          e.toString().contains('404')) {
        print('📝 BudgetController: No enrollments found for profile - this is normal');
        enrollments = []; // Asegurar lista vacía
        errorMessage = null; // No mostrar como error
      } else {
        errorMessage = 'Error al cargar enrolamientos: $e';
      }
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Crear presupuesto
  Future<void> createBudget(NewBudgetDTO dto) async {
    _setLoading(true);
    try {
      print('BudgetController: Creating budget with data: ${dto.toJson()}');
      final newBudget = await _service.addBudget(dto);
      print('BudgetController: Budget created successfully: ${newBudget.toJson()}');
      budgets.add(newBudget);
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('BudgetController: Error creating budget: $e');
      errorMessage = 'Error al crear presupuesto: $e';
      rethrow; // Relanzar la excepción para que el widget pueda manejarla
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Actualizar presupuesto individual
  Future<void> updateBudget(UpdateBudgetDTO dto) async {
    print('BudgetController: updateBudget called with DTO: ${dto.toJson()}');
    _setLoading(true);
    try {
      print('BudgetController: Calling service.updateBudget');
      final updated = await _service.updateBudget(dto);
      print('BudgetController: Service returned updated budget: ${updated.toJson()}');
      final index = budgets.indexWhere((b) => b.id == dto.id);
      if (index != -1) {
        budgets[index] = updated;
        print('BudgetController: Updated budget at index $index');
      } else {
        print('BudgetController: Budget with ID ${dto.id} not found in local list');
      }
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('BudgetController: Error updating budget: $e');
      errorMessage = 'Error al actualizar presupuesto: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Actualizar múltiples presupuestos
  Future<void> updateBudgetsBatch(List<UpdateBudgetDTO> dtos) async {
    print('BudgetController: updateBudgetsBatch called with ${dtos.length} DTOs');
    for (final dto in dtos) {
      print('BudgetController: DTO: ${dto.toJson()}');
    }
    _setLoading(true);
    try {
      print('BudgetController: Calling service.updateBudgetsBatch');
      await _service.updateBudgetsBatch(dtos);
      print('BudgetController: Batch update completed, updating local budgets');
      
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
          print('BudgetController: Updated budget at index $index with ID ${dto.id}');
        } else {
          print('BudgetController: Budget with ID ${dto.id} not found in local list');
        }
      }
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('BudgetController: Error in batch update: $e');
      errorMessage = 'Error al actualizar presupuestos: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Eliminar presupuesto
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

  // ✅ Eliminar múltiples presupuestos
  Future<void> deleteBudgetsBatch(List<int> ids) async {
    print('BudgetController: deleteBudgetsBatch called with ${ids.length} IDs: $ids');
    _setLoading(true);
    try {
      print('BudgetController: Calling service.deleteBudgetsBatch');
      await _service.deleteBudgetsBatch(ids);
      print('BudgetController: Batch delete completed, removing from local budgets');
      
      // Eliminar los presupuestos de la lista local
      budgets.removeWhere((budget) => ids.contains(budget.id));
      print('BudgetController: Removed ${ids.length} budgets from local list');
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('BudgetController: Error in batch delete: $e');
      errorMessage = 'Error al eliminar presupuestos: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Asignar presupuesto a perfil
  Future<void> enrollProfileToBudget(int profileId, int budgetId) async {
    try {
      print('BudgetController: Enrolling profile $profileId to budget $budgetId');
      await _service.enrollProfileToBudget(profileId, budgetId);
      print('BudgetController: Profile enrolled successfully');
    } catch (e) {
      print('BudgetController: Error enrolling profile to budget: $e');
      rethrow;
    }
  }

  // ✅ Eliminar múltiples enrollments
  Future<void> deleteEnrollmentsBatch(List<int> ids) async {
    print('BudgetController: deleteEnrollmentsBatch called with ${ids.length} IDs: $ids');
    _setLoading(true);
    try {
      print('BudgetController: Calling service.deleteEnrollmentsBatch');
      await _service.deleteEnrollmentsBatch(ids);
      print('BudgetController: Batch enrollment delete completed');
      
      // Actualizar la lista local de enrollments
      enrollments.removeWhere((enrollment) => ids.contains(enrollment.id));
      print('BudgetController: Removed ${ids.length} enrollments from local list');
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('BudgetController: Error in batch enrollment delete: $e');
      errorMessage = 'Error al eliminar asignaciones: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Asignar múltiples perfiles a presupuestos
  Future<void> enrollProfileToBudgetBatch(List<Map<String, int>> enrollments) async {
    print('BudgetController: enrollProfileToBudgetBatch called with ${enrollments.length} enrollments');
    _setLoading(true);
    try {
      print('BudgetController: Calling service.enrollProfileToBudgetBatch');
      await _service.enrollProfileToBudgetBatch(enrollments);
      print('BudgetController: Batch enrollment completed successfully');
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('BudgetController: Error in batch enrollment: $e');
      errorMessage = 'Error al asignar presupuestos: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Obtener enrollments por usuario
  Future<void> loadUserEnrollments() async {
    print('BudgetController: loadUserEnrollments() called');
    _setLoading(true);
    try {
      print('BudgetController: Calling service.getEnrollmentsByUser()');
      enrollments = await _service.getEnrollmentsByUser();
      print('BudgetController: Received ${enrollments.length} user enrollments');
      errorMessage = null;
    } catch (e) {
      print('BudgetController: Error loading user enrollments: $e');
      errorMessage = 'Error al cargar asignaciones del usuario: $e';
    } finally {
      _setLoading(false);
      print('BudgetController: loadUserEnrollments() finished, loading: $isLoading');
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
