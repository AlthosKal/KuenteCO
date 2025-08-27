import 'package:flutter/material.dart';
import '../core/services/app/budget_service.dart';
import '../dto/app/budget/budget_dto.dart';
import '../dto/app/budget/budget_enrollment_dto.dart';
import '../dto/app/budget/budget_summary_dto.dart';
import '../dto/app/budget/budget_vs_actual_dto.dart';
import '../dto/app/budget/new_budget_dto.dart';

class BudgetController extends ChangeNotifier {
  final BudgetService _service;

  BudgetController(this._service);

  List<BudgetDTO> budgets = [];
  List<BudgetVsActualDTO> budgetComparison = [];
  BudgetSummaryDTO? budgetSummary;
  List<BudgetEnrollmentDTO> enrollments = [];

  bool isLoading = false;
  String? errorMessage;

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
      errorMessage = 'Error al cargar presupuestos: $e';
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
    print('BudgetController: loadEnrollments() called');
    _setLoading(true);
    try {
      print('BudgetController: Calling service.getEnrollments()');
      enrollments = await _service.getEnrollments();
      print('BudgetController: Received ${enrollments.length} enrollments');
      errorMessage = null;
    } catch (e) {
      print('BudgetController: Error loading enrollments: $e');
      errorMessage = 'Error al cargar enrolamientos: $e';
    } finally {
      _setLoading(false);
      print('BudgetController: loadEnrollments() finished, loading: $isLoading');
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

  // ✅ Actualizar presupuesto
  Future<void> updateBudget(BudgetDTO dto) async {
    _setLoading(true);
    try {
      final updated = await _service.updateBudget(dto);
      final index = budgets.indexWhere((b) => b.id == dto.id);
      if (index != -1) budgets[index] = updated;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al actualizar presupuesto: $e';
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

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
