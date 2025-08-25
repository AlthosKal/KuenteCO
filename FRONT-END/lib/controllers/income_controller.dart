import 'package:flutter/material.dart';
import '../core/services/app/income_service.dart';
import '../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../dto/app/transaction/kuenteco/transaction_summary_dto.dart';

class IncomeController extends ChangeNotifier {
  final IncomeService _service;

  bool isLoading = false;
  String? errorMessage;

  List<TransactionDetailDTO> incomes = [];
  List<TransactionSummaryDTO> incomeSummaries = [];
  TransactionDetailDTO? currentIncome;
  
  // Estadísticas específicas de ingresos
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

  // 📌 Cargar todos los ingresos
  Future<void> loadIncomes() async {
    _setLoading(true);
    try {
      print('🔄 IncomeController: Loading all incomes from server...');
      incomes = await _service.getAllIncomes();
      print('✅ IncomeController: Loaded ${incomes.length} incomes from server');
      
      // Log de todos los ingresos para debug
      for (int i = 0; i < incomes.length; i++) {
        print('   Income $i: ID=${incomes[i].id}, Name="${incomes[i].name}", Amount=${incomes[i].amount}');
      }
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ IncomeController: Error loading incomes: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar ingreso por ID
  Future<void> loadIncomeById(int id) async {
    _setLoading(true);
    try {
      print('🔄 IncomeController: Loading income ID: $id');
      currentIncome = await _service.getIncomeById(id);
      print('✅ IncomeController: Loaded income: ${currentIncome?.name}');
      _setError(null);
    } catch (e) {
      print('❌ IncomeController: Error loading income: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar resumen de ingresos
  Future<void> loadIncomeSummaries() async {
    _setLoading(true);
    try {
      print('🔄 IncomeController: Loading income summaries...');
      incomeSummaries = await _service.getIncomeSummary();
      print('✅ IncomeController: Loaded ${incomeSummaries.length} income summaries');
      _setError(null);
    } catch (e) {
      print('❌ IncomeController: Error loading income summaries: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar ingresos filtrados
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
      print('🔄 IncomeController: Loading filtered incomes...');
      incomes = await _service.getFilteredIncomes(
        categoryId: categoryId,
        budgetId: budgetId,
        profileId: profileId,
        from: from,
        to: to,
        minAmount: minAmount,
        maxAmount: maxAmount,
      );
      print('✅ IncomeController: Loaded ${incomes.length} filtered incomes');
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ IncomeController: Error loading filtered incomes: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // 📌 Crear ingreso
  Future<void> addIncome(NewTransactionDTO dto) async {
    _setError(null);
    
    try {
      print('📌 IncomeController: Creating income...');
      final createdIncome = await _service.addIncome(dto);
      print('✅ IncomeController: Income created with ID: ${createdIncome.id}');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('❌ IncomeController: Error creating income: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Crear múltiples ingresos (batch)
  Future<void> addIncomesBatch(List<NewTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 IncomeController: Creating ${dtos.length} incomes in batch...');
      final createdIncomes = await _service.addIncomesBatch(dtos);
      print('✅ IncomeController: Batch creation completed. Created ${createdIncomes.length} incomes');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('❌ IncomeController: Error in batch creation: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar ingreso
  Future<void> updateIncome(UpdateTransactionDTO dto) async {
    print('🔄 IncomeController: Starting update for income ID: ${dto.id}');
    
    _setError(null);
    
    try {
      print('🔄 IncomeController: Calling service.updateIncome...');
      final updatedIncome = await _service.updateIncome(dto);
      print('✅ IncomeController: Income updated successfully: ${updatedIncome.name}');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('❌ IncomeController: Error during update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar múltiples ingresos (batch)
  Future<void> updateIncomesBatch(List<UpdateTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 IncomeController: Updating ${dtos.length} incomes in batch...');
      final updatedIncomes = await _service.updateIncomesBatch(dtos);
      print('✅ IncomeController: Batch update completed. Updated ${updatedIncomes.length} incomes');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('❌ IncomeController: Error in batch update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Eliminar ingreso
  Future<void> deleteIncome(int id) async {
    _setLoading(true);
    try {
      print('📌 IncomeController: Deleting income ID: $id');
      await _service.deleteIncome(id);
      print('✅ IncomeController: Income deleted successfully');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
      _setError(null);
    } catch (e) {
      print('❌ IncomeController: Error deleting income: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Eliminar múltiples ingresos (batch)
  Future<void> deleteIncomesBatch(List<int> ids) async {
    _setError(null);
    
    try {
      print('📌 IncomeController: Deleting ${ids.length} incomes in batch...');
      await _service.deleteIncomesBatch(ids);
      print('✅ IncomeController: Batch deletion completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadIncomes();
    } catch (e) {
      print('❌ IncomeController: Error in batch deletion: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= ANALYSIS METHODS =============

  // 📌 Obtener análisis mensual de ingresos
  Future<void> loadMonthlyIncomeAnalysis(int year, int month) async {
    _setLoading(true);
    try {
      print('🔄 IncomeController: Loading monthly income analysis for $year-$month...');
      final analysis = await _service.getMonthlyIncomeAnalysis(year, month);
      print('✅ IncomeController: Monthly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('❌ IncomeController: Error loading monthly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener análisis anual de ingresos
  Future<void> loadYearlyIncomeAnalysis(int year) async {
    _setLoading(true);
    try {
      print('🔄 IncomeController: Loading yearly income analysis for $year...');
      final analysis = await _service.getYearlyIncomeAnalysis(year);
      print('✅ IncomeController: Yearly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('❌ IncomeController: Error loading yearly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener ingresos por categoría
  Future<void> loadIncomesByCategory(int categoryId) async {
    _setLoading(true);
    try {
      print('🔄 IncomeController: Loading incomes by category ID: $categoryId...');
      final incomesByCategory = await _service.getIncomesByCategory(categoryId);
      print('✅ IncomeController: Loaded ${incomesByCategory.length} incomes for category');
      incomes = incomesByCategory;
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ IncomeController: Error loading incomes by category: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= UTILITY METHODS =============

  // 📌 Limpiar datos
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

  // 📌 Obtener ingreso por ID (desde la lista local)
  TransactionDetailDTO? getIncomeById(int id) {
    try {
      return incomes.firstWhere((income) => income.id == id);
    } catch (e) {
      return null;
    }
  }

  // 📌 Obtener ingresos por categoría (desde la lista local)
  List<TransactionDetailDTO> getIncomesByCategory(int categoryId) {
    return incomes.where((income) => income.categoryId == categoryId).toList();
  }

  // 📌 Obtener ingresos por rango de fechas (desde la lista local)
  List<TransactionDetailDTO> getIncomesByDateRange(DateTime from, DateTime to) {
    return incomes.where((income) {
      final incomeDate = DateTime.parse(income.date);
      return incomeDate.isAfter(from.subtract(const Duration(days: 1))) &&
             incomeDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  // 📌 Obtener ingresos por rango de monto (desde la lista local)
  List<TransactionDetailDTO> getIncomesByAmountRange(double minAmount, double maxAmount) {
    return incomes.where((income) => 
        income.amount >= minAmount && income.amount <= maxAmount).toList();
  }

  // 📌 Verificar si hay ingresos cargados
  bool get hasIncomes => incomes.isNotEmpty;

  // 📌 Obtener el mayor ingreso
  TransactionDetailDTO? get highestIncome {
    if (incomes.isEmpty) return null;
    return incomes.reduce((current, next) => 
        current.amount > next.amount ? current : next);
  }

  // 📌 Obtener el menor ingreso
  TransactionDetailDTO? get lowestIncome {
    if (incomes.isEmpty) return null;
    return incomes.reduce((current, next) => 
        current.amount < next.amount ? current : next);
  }

  // 📌 Obtener ingresos recientes (últimos 30 días)
  List<TransactionDetailDTO> get recentIncomes {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return incomes.where((income) {
      // Use timestamp if available, otherwise parse date string
      final incomeDate = income.timestamp ?? DateTime.parse(income.date);
      return incomeDate.isAfter(thirtyDaysAgo);
    }).toList();
  }
}
