import 'package:flutter/material.dart';

import '../../core/services/app/expenses_service.dart';
import '../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../../dto/app/transaction/kuenteco/update_transaction_dto.dart';

class ExpensesController extends ChangeNotifier {
  final ExpensesService _service;

  bool isLoading = false;
  String? errorMessage;

  List<TransactionDetailDTO> expenses = [];
  List<TransactionSummaryDTO> expenseSummaries = [];
  TransactionDetailDTO? currentExpense;
  
  // Estadísticas específicas de gastos
  double totalExpenseAmount = 0.0;
  double averageExpenseAmount = 0.0;
  int totalExpenseCount = 0;

  ExpensesController(this._service);

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void _updateStatistics() {
    totalExpenseCount = expenses.length;
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    totalExpenseAmount = total;
    averageExpenseAmount = totalExpenseCount > 0 ? totalExpenseAmount / totalExpenseCount : 0.0;
  }

  // ============= LOAD OPERATIONS =============

  // 📌 Cargar todos los gastos
  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      print('🔄 ExpensesController: Loading all expenses from server...');
      expenses = await _service.getAllExpenses();
      print('✅ ExpensesController: Loaded ${expenses.length} expenses from server');
      
      // Log de todos los gastos para debug
      for (int i = 0; i < expenses.length; i++) {
        print('   Expense $i: ID=${expenses[i].id}, Name="${expenses[i].name}", Amount=${expenses[i].amount}');
      }
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error loading expenses: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar gasto por ID
  Future<void> loadExpenseById(int id) async {
    _setLoading(true);
    try {
      print('🔄 ExpensesController: Loading expense ID: $id');
      currentExpense = await _service.getExpenseById(id);
      print('✅ ExpensesController: Loaded expense: ${currentExpense?.name}');
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error loading expense: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar resumen de gastos
  Future<void> loadExpenseSummaries() async {
    _setLoading(true);
    try {
      print('🔄 ExpensesController: Loading expense summaries...');
      expenseSummaries = await _service.getExpenseSummary();
      print('✅ ExpensesController: Loaded ${expenseSummaries.length} expense summaries');
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error loading expense summaries: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar gastos filtrados
  Future<void> loadFilteredExpenses({
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
      print('🔄 ExpensesController: Loading filtered expenses...');
      // Usando métodos existentes del servicio según los filtros
      if (categoryId != null) {
        expenses = await _service.getExpensesByCategory(categoryId);
      } else if (from != null && to != null) {
        expenses = await _service.getExpensesByDateRange(from: from, to: to);
      } else if (minAmount != null || maxAmount != null) {
        expenses = await _service.getExpensesByAmountRange(
          minAmount: minAmount,
          maxAmount: maxAmount,
        );
      } else if (profileId != null) {
        expenses = await _service.getExpensesByProfile(profileId);
      } else {
        expenses = await _service.getAllExpenses();
      }
      print('✅ ExpensesController: Loaded ${expenses.length} filtered expenses');
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error loading filtered expenses: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // 📌 Crear gasto
  Future<void> addExpense(NewTransactionDTO dto) async {
    _setError(null);
    
    try {
      print('📌 ExpensesController: Creating expense...');
      final createdExpense = await _service.createExpense(dto);
      print('✅ ExpensesController: Expense created with ID: ${createdExpense.id}');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('❌ ExpensesController: Error creating expense: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Crear múltiples gastos (batch)
  Future<void> addExpensesBatch(List<NewTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 ExpensesController: Creating ${dtos.length} expenses in batch...');
      final createdExpenses = await _service.createExpensesBatch(dtos);
      print('✅ ExpensesController: Batch creation completed. Created ${createdExpenses.length} expenses');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('❌ ExpensesController: Error in batch creation: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar gasto
  Future<void> updateExpense(UpdateTransactionDTO dto) async {
    print('🔄 ExpensesController: Starting update for expense ID: ${dto.id}');
    
    _setError(null);
    
    try {
      print('🔄 ExpensesController: Calling service.updateExpense...');
      final updatedExpense = await _service.updateExpense(dto);
      print('✅ ExpensesController: Expense updated successfully: ${updatedExpense.name}');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('❌ ExpensesController: Error during update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar múltiples gastos (batch)
  Future<void> updateExpensesBatch(List<UpdateTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 ExpensesController: Updating ${dtos.length} expenses in batch...');
      final updatedExpenses = await _service.updateExpensesBatch(dtos);
      print('✅ ExpensesController: Batch update completed. Updated ${updatedExpenses.length} expenses');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('❌ ExpensesController: Error in batch update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Eliminar gasto
  Future<void> deleteExpense(int id) async {
    _setLoading(true);
    try {
      print('📌 ExpensesController: Deleting expense ID: $id');
      await _service.deleteExpense(id);
      print('✅ ExpensesController: Expense deleted successfully');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error deleting expense: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Eliminar múltiples gastos (batch)
  Future<void> deleteExpensesBatch(List<int> ids) async {
    _setError(null);
    
    try {
      print('📌 ExpensesController: Deleting ${ids.length} expenses in batch...');
      await _service.deleteExpensesBatch(ids);
      print('✅ ExpensesController: Batch deletion completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('❌ ExpensesController: Error in batch deletion: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= ANALYSIS METHODS =============

  // 📌 Obtener análisis mensual de gastos
  Future<void> loadMonthlyExpenseAnalysis(int year, int month) async {
    _setLoading(true);
    try {
      print('🔄 ExpensesController: Loading monthly expense analysis for $year-$month...');
      // Implementando análisis mensual usando datos existentes
      final from = '$year-${month.toString().padLeft(2, '0')}-01';
      final to = '$year-${month.toString().padLeft(2, '0')}-31';
      final monthlyExpenses = await _service.getExpensesByDateRange(from: from, to: to);
      double total = 0.0;
      for (final expense in monthlyExpenses) {
        total += expense.amount;
      }
      final analysis = {'totalAmount': total, 'count': monthlyExpenses.length};
      print('✅ ExpensesController: Monthly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error loading monthly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener análisis anual de gastos
  Future<void> loadYearlyExpenseAnalysis(int year) async {
    _setLoading(true);
    try {
      print('🔄 ExpensesController: Loading yearly expense analysis for $year...');
      // Implementando análisis anual usando datos existentes
      final monthlyTotals = await _service.getMonthlyExpenseTotals(year);
      double totalAmount = 0.0;
      int totalCount = 0;
      for (final monthTotal in monthlyTotals.values) {
        totalAmount += monthTotal;
      }
      // Obtener el conteo total del año
      final yearlyExpenses = await _service.getExpensesByDateRange(
        from: '$year-01-01', 
        to: '$year-12-31',
      );
      totalCount = yearlyExpenses.length;
      final analysis = {'totalAmount': totalAmount, 'count': totalCount};
      print('✅ ExpensesController: Yearly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error loading yearly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener gastos por categoría
  Future<void> loadExpensesByCategory() async {
    _setLoading(true);
    try {
      print('🔄 ExpensesController: Loading expenses by category...');
      // Usando método existente para obtener gastos categorizados
      final expensesByCategory = await _service.getExpensesByCategoryBreakdown();
      print('✅ ExpensesController: Loaded expenses for ${expensesByCategory.length} categories');
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error loading expenses by category: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= BUDGET METHODS =============

  // 📌 Obtener gastos por presupuesto
  Future<void> loadExpensesByBudget(int budgetId) async {
    _setLoading(true);
    try {
      print('🔄 ExpensesController: Loading expenses for budget ID: $budgetId');
      final expensesByBudget = await _service.getExpensesByBudget(budgetId);
      print('✅ ExpensesController: Loaded ${expensesByBudget.length} expenses for budget');
      _setError(null);
    } catch (e) {
      print('❌ ExpensesController: Error loading expenses by budget: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Verificar límite de presupuesto
  Future<bool> checkBudgetLimit(int budgetId, double amount) async {
    try {
      print('🔄 ExpensesController: Checking budget limit for budget ID: $budgetId, amount: $amount');
      final withinLimit = await _service.checkBudgetLimit(budgetId, amount);
      print('✅ ExpensesController: Budget limit check - Within limit: $withinLimit');
      return withinLimit;
    } catch (e) {
      print('❌ ExpensesController: Error checking budget limit: $e');
      return false;
    }
  }

  // ============= UTILITY METHODS =============

  // 📌 Limpiar datos
  void clearData() {
    expenses.clear();
    expenseSummaries.clear();
    currentExpense = null;
    totalExpenseAmount = 0.0;
    averageExpenseAmount = 0.0;
    totalExpenseCount = 0;
    _setError(null);
    notifyListeners();
  }

  // 📌 Obtener gasto por ID (desde la lista local)
  TransactionDetailDTO? getExpenseById(int id) {
    try {
      return expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  // 📌 Obtener gastos por categoría (desde la lista local)
  List<TransactionDetailDTO> getExpensesByCategory(int categoryId) {
    return expenses.where((expense) => expense.categoryId == categoryId).toList();
  }

  // 📌 Obtener gastos por rango de fechas (desde la lista local)
  List<TransactionDetailDTO> getExpensesByDateRange(DateTime from, DateTime to) {
    return expenses.where((expense) {
      final expenseDate = expense.transactionDate ?? DateTime.now();
      return expenseDate.isAfter(from.subtract(const Duration(days: 1))) &&
             expenseDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  // 📌 Obtener gastos por rango de monto (desde la lista local)
  List<TransactionDetailDTO> getExpensesByAmountRange(double minAmount, double maxAmount) {
    return expenses.where((expense) => 
        expense.amount >= minAmount && expense.amount <= maxAmount).toList();
  }

  // 📌 Verificar si hay gastos cargados
  bool get hasExpenses => expenses.isNotEmpty;

  // 📌 Obtener el mayor gasto
  TransactionDetailDTO? get highestExpense {
    if (expenses.isEmpty) return null;
    return expenses.reduce((current, next) => 
        current.amount > next.amount ? current : next);
  }

  // 📌 Obtener el menor gasto
  TransactionDetailDTO? get lowestExpense {
    if (expenses.isEmpty) return null;
    return expenses.reduce((current, next) => 
        current.amount < next.amount ? current : next);
  }

  // 📌 Obtener gastos recientes (últimos 30 días)
  List<TransactionDetailDTO> get recentExpenses {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return expenses.where((expense) {
      final expenseDate = expense.transactionDate ?? DateTime.now();
      return expenseDate.isAfter(thirtyDaysAgo);
    }).toList();
  }

  // 📌 Obtener gastos por presupuesto (desde la lista local)
  List<TransactionDetailDTO> getExpensesByBudgetLocal(int budgetId) {
    return expenses.where((expense) => expense.budgetId == budgetId).toList();
  }

  // 📌 Calcular porcentaje del presupuesto usado
  double calculateBudgetUsagePercentage(int budgetId, double budgetLimit) {
    final budgetExpenses = getExpensesByBudgetLocal(budgetId);
    double totalSpent = 0.0;
    for (final expense in budgetExpenses) {
      totalSpent += expense.amount;
    }
    return budgetLimit > 0 ? (totalSpent / budgetLimit) * 100 : 0.0;
  }
}
