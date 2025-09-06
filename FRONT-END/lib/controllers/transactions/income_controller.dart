import 'package:flutter/material.dart';

import '../../core/services/app/income_service.dart';
import '../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../../dto/app/transaction/kuenteco/update_transaction_dto.dart';

class IncomeController extends ChangeNotifier {
  final IncomeService _service;

  bool isLoading = false;
  String? errorMessage;

  List<TransactionDetailDTO> incomes = [];
  List<TransactionSummaryDTO> incomeSummaries = [];
  TransactionDetailDTO? currentIncome;
  
  // EstadÃ­sticas especÃ­ficas de ingresos
  double totalIncomeAmount = 0.0;
  double averageIncomeAmount = 0.0;
  int totalIncomeCount = 0;

  IncomeController(this._service);

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void _updateStatistics() {
    totalIncomeCount = incomes.length;
    totalIncomeAmount = incomes.fold(0.0, (sum, income) => sum + income.amount);
    averageIncomeAmount = totalIncomeCount > 0 ? totalIncomeAmount / totalIncomeCount : 0.0;
  }

  // ============= LOAD OPERATIONS =============

  // ð Cargar todos los ingresos
  Future<void> loadIncomes() async {
    _setLoading(true);
    try {
      print('ð IncomeController: Loading all incomes from server...');
      incomes = await _service.getAllIncomes();
      print('â IncomeController: Loaded ${incomes.length} incomes from server');
      
      // Log de todos los ingresos para debug
      for (int i = 0; i < incomes.length; i++) {
        print('   Income $i: ID=${incomes[i].id}, Name="${incomes[i].name}", Amount=${incomes[i].amount}');
      }
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('â IncomeController: Error loading incomes: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar ingreso por ID
  Future<void> loadIncomeById(int id) async {
    _setLoading(true);
    try {
      print('ð IncomeController: Loading income ID: $id');
      currentIncome = await _service.getIncomeById(id);
      print('â IncomeController: Loaded income: ${currentIncome?.name}');
      _setError(null);
    } catch (e) {
      print('â IncomeController: Error loading income: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar resumen de ingresos
  Future<void> loadIncomeSummaries() async {
    _setLoading(true);
    try {
      print('ð IncomeController: Loading income summaries...');
      incomeSummaries = await _service.getIncomeSummary();
      print('â IncomeController: Loaded ${incomeSummaries.length} income summaries');
      _setError(null);
    } catch (e) {
      print('â IncomeController: Error loading income summaries: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar ingresos filtrados
  Future<void> loadFilteredIncomes({
    int? categoryId,
    int? budgetId,
    int? profileId,
    String? from,
    String? to,
    double? minAmount,
    double? maxAmount,
  }) async {
    _setLoading(true);
    try {
      print('ð IncomeController: Loading filtered incomes...');
      incomes = await _service.getFilteredIncomes(
        categoryId: categoryId,
        budgetId: budgetId,
        profileId: profileId,
        from: from,
        to: to,
        minAmount: minAmount,
        maxAmount: maxAmount,
      );
      print('â IncomeController: Loaded ${incomes.length} filtered incomes');
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('â IncomeController: Error loading filtered incomes: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // ð Crear ingreso
  Future<void> addIncome(NewTransactionDTO dto) async {
    _setError(null);
    
    try {
      print('ð IncomeController: Creating income...');
      final createdIncome = await _service.addIncome(dto);
      print('â IncomeController: Income created with ID: ${createdIncome.id}');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('â IncomeController: Error creating income: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Crear mÃºltiples ingresos (batch)
  Future<void> addIncomesBatch(List<NewTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('ð IncomeController: Creating ${dtos.length} incomes in batch...');
      final createdIncomes = await _service.addIncomesBatch(dtos);
      print('â IncomeController: Batch creation completed. Created ${createdIncomes.length} incomes');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('â IncomeController: Error in batch creation: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Actualizar ingreso
  Future<void> updateIncome(UpdateTransactionDTO dto) async {
    print('ð IncomeController: Starting update for income ID: ${dto.id}');
    
    _setError(null);
    
    try {
      print('ð IncomeController: Calling service.updateIncome...');
      final updatedIncome = await _service.updateIncome(dto);
      print('â IncomeController: Income updated successfully: ${updatedIncome.name}');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('â IncomeController: Error during update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Actualizar mÃºltiples ingresos (batch)
  Future<void> updateIncomesBatch(List<UpdateTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('ð IncomeController: Updating ${dtos.length} incomes in batch...');
      final updatedIncomes = await _service.updateIncomesBatch(dtos);
      print('â IncomeController: Batch update completed. Updated ${updatedIncomes.length} incomes');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('â IncomeController: Error in batch update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Eliminar ingreso
  Future<void> deleteIncome(int id) async {
    _setLoading(true);
    try {
      print('ð IncomeController: Deleting income ID: $id');
      await _service.deleteIncome(id);
      print('â IncomeController: Income deleted successfully');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
      _setError(null);
    } catch (e) {
      print('â IncomeController: Error deleting income: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ð Eliminar mÃºltiples ingresos (batch)
  Future<void> deleteIncomesBatch(List<int> ids) async {
    _setError(null);
    
    try {
      print('ð IncomeController: Deleting ${ids.length} incomes in batch...');
      await _service.deleteIncomesBatch(ids);
      print('â IncomeController: Batch deletion completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('â IncomeController: Error in batch deletion: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= ANALYSIS METHODS =============

  // ð Obtener anÃ¡lisis mensual de ingresos
  Future<void> loadMonthlyIncomeAnalysis(int year, int month) async {
    _setLoading(true);
    try {
      print('ð IncomeController: Loading monthly income analysis for $year-$month...');
      final analysis = await _service.getMonthlyIncomeAnalysis(year, month);
      print('â IncomeController: Monthly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('â IncomeController: Error loading monthly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Obtener anÃ¡lisis anual de ingresos
  Future<void> loadYearlyIncomeAnalysis(int year) async {
    _setLoading(true);
    try {
      print('ð IncomeController: Loading yearly income analysis for $year...');
      final analysis = await _service.getYearlyIncomeAnalysis(year);
      print('â IncomeController: Yearly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('â IncomeController: Error loading yearly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Obtener ingresos por categorÃ­a
  Future<void> loadIncomesByCategory(int categoryId) async {
    _setLoading(true);
    try {
      print('ð IncomeController: Loading incomes by category ID: $categoryId...');
      final incomesByCategory = await _service.getIncomesByCategory(categoryId);
      print('â IncomeController: Loaded ${incomesByCategory.length} incomes for category');
      incomes = incomesByCategory;
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('â IncomeController: Error loading incomes by category: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= UTILITY METHODS =============

  // ð Limpiar datos
  void clearData() {
    incomes.clear();
    incomeSummaries.clear();
    currentIncome = null;
    totalIncomeAmount = 0.0;
    averageIncomeAmount = 0.0;
    totalIncomeCount = 0;
    _setError(null);
    notifyListeners();
  }

  // ð Obtener ingreso por ID (desde la lista local)
  TransactionDetailDTO? getIncomeById(int id) {
    try {
      return incomes.firstWhere((income) => income.id == id);
    } catch (e) {
      return null;
    }
  }

  // ð Obtener ingresos por categorÃ­a (desde la lista local)
  List<TransactionDetailDTO> getIncomesByCategory(int categoryId) {
    return incomes.where((income) => income.categoryId == categoryId).toList();
  }

  // ð Obtener ingresos por rango de fechas (desde la lista local)
  List<TransactionDetailDTO> getIncomesByDateRange(DateTime from, DateTime to) {
    return incomes.where((income) {
      final incomeDate = DateTime.parse(income.date);
      return incomeDate.isAfter(from.subtract(const Duration(days: 1))) &&
             incomeDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  // ð Obtener ingresos por rango de monto (desde la lista local)
  List<TransactionDetailDTO> getIncomesByAmountRange(double minAmount, double maxAmount) {
    return incomes.where((income) => 
        income.amount >= minAmount && income.amount <= maxAmount).toList();
  }

  // ð Verificar si hay ingresos cargados
  bool get hasIncomes => incomes.isNotEmpty;

  // ð Obtener el mayor ingreso
  TransactionDetailDTO? get highestIncome {
    if (incomes.isEmpty) return null;
    return incomes.reduce((current, next) => 
        current.amount > next.amount ? current : next);
  }

  // ð Obtener el menor ingreso
  TransactionDetailDTO? get lowestIncome {
    if (incomes.isEmpty) return null;
    return incomes.reduce((current, next) => 
        current.amount < next.amount ? current : next);
  }

  // ð Obtener ingresos recientes (Ãºltimos 30 dÃ­as)
  List<TransactionDetailDTO> get recentIncomes {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return incomes.where((income) {
      // Use timestamp if available, otherwise parse date string
      final incomeDate = income.transactionDate ?? DateTime.parse(income.date);
      return incomeDate.isAfter(thirtyDaysAgo);
    }).toList();
  }
}
