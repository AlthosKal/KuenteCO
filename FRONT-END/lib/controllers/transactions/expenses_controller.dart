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
  
  // EstadÃ­sticas especÃ­ficas de gastos
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

  // ð Cargar todos los gastos
  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      print('ð ExpensesController: Loading all expenses from server...');
      expenses = await _service.getAllExpenses();
      print('â ExpensesController: Loaded ${expenses.length} expenses from server');
      
      // Log de todos los gastos para debug
      for (int i = 0; i < expenses.length; i++) {
        print('   Expense $i: ID=${expenses[i].id}, Name="${expenses[i].name}", Amount=${expenses[i].amount}');
      }
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error loading expenses: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar gasto por ID
  Future<void> loadExpenseById(int id) async {
    _setLoading(true);
    try {
      print('ð ExpensesController: Loading expense ID: $id');
      currentExpense = await _service.getExpenseById(id);
      print('â ExpensesController: Loaded expense: ${currentExpense?.name}');
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error loading expense: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar resumen de gastos
  Future<void> loadExpenseSummaries() async {
    _setLoading(true);
    try {
      print('ð ExpensesController: Loading expense summaries...');
      expenseSummaries = await _service.getExpenseSummary();
      print('â ExpensesController: Loaded ${expenseSummaries.length} expense summaries');
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error loading expense summaries: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar gastos filtrados
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
      print('ð ExpensesController: Loading filtered expenses...');
      // Usando mÃ©todos existentes del servicio segÃºn los filtros
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
      print('â ExpensesController: Loaded ${expenses.length} filtered expenses');
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error loading filtered expenses: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // ð Crear gasto
  Future<void> addExpense(NewTransactionDTO dto) async {
    _setError(null);
    
    try {
      print('ð ExpensesController: Creating expense...');
      final createdExpense = await _service.createExpense(dto);
      print('â ExpensesController: Expense created with ID: ${createdExpense.id}');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('â ExpensesController: Error creating expense: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Crear mÃºltiples gastos (batch)
  Future<void> addExpensesBatch(List<NewTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('ð ExpensesController: Creating ${dtos.length} expenses in batch...');
      final createdExpenses = await _service.createExpensesBatch(dtos);
      print('â ExpensesController: Batch creation completed. Created ${createdExpenses.length} expenses');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('â ExpensesController: Error in batch creation: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Actualizar gasto
  Future<void> updateExpense(UpdateTransactionDTO dto) async {
    print('ð ExpensesController: Starting update for expense ID: ${dto.id}');
    
    _setError(null);
    
    try {
      print('ð ExpensesController: Calling service.updateExpense...');
      final updatedExpense = await _service.updateExpense(dto);
      print('â ExpensesController: Expense updated successfully: ${updatedExpense.name}');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('â ExpensesController: Error during update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Actualizar mÃºltiples gastos (batch)
  Future<void> updateExpensesBatch(List<UpdateTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('ð ExpensesController: Updating ${dtos.length} expenses in batch...');
      final updatedExpenses = await _service.updateExpensesBatch(dtos);
      print('â ExpensesController: Batch update completed. Updated ${updatedExpenses.length} expenses');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('â ExpensesController: Error in batch update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Eliminar gasto
  Future<void> deleteExpense(int id) async {
    _setLoading(true);
    try {
      print('ð ExpensesController: Deleting expense ID: $id');
      await _service.deleteExpense(id);
      print('â ExpensesController: Expense deleted successfully');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error deleting expense: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ð Eliminar mÃºltiples gastos (batch)
  Future<void> deleteExpensesBatch(List<int> ids) async {
    _setError(null);
    
    try {
      print('ð ExpensesController: Deleting ${ids.length} expenses in batch...');
      await _service.deleteExpensesBatch(ids);
      print('â ExpensesController: Batch deletion completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadExpenses();
    } catch (e) {
      print('â ExpensesController: Error in batch deletion: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= ANALYSIS METHODS =============

  // ð Obtener anÃ¡lisis mensual de gastos
  Future<void> loadMonthlyExpenseAnalysis(int year, int month) async {
    _setLoading(true);
    try {
      print('ð ExpensesController: Loading monthly expense analysis for $year-$month...');
      // Implementando anÃ¡lisis mensual usando datos existentes
      final from = '$year-${month.toString().padLeft(2, '0')}-01';
      final to = '$year-${month.toString().padLeft(2, '0')}-31';
      final monthlyExpenses = await _service.getExpensesByDateRange(from: from, to: to);
      double total = 0.0;
      for (final expense in monthlyExpenses) {
        total += expense.amount;
      }
      final analysis = {'totalAmount': total, 'count': monthlyExpenses.length};
      print('â ExpensesController: Monthly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error loading monthly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Obtener anÃ¡lisis anual de gastos
  Future<void> loadYearlyExpenseAnalysis(int year) async {
    _setLoading(true);
    try {
      print('ð ExpensesController: Loading yearly expense analysis for $year...');
      // Implementando anÃ¡lisis anual usando datos existentes
      final monthlyTotals = await _service.getMonthlyExpenseTotals(year);
      double totalAmount = 0.0;
      int totalCount = 0;
      for (final monthTotal in monthlyTotals.values) {
        totalAmount += monthTotal;
      }
      // Obtener el conteo total del aÃ±o
      final yearlyExpenses = await _service.getExpensesByDateRange(
        from: '$year-01-01', 
        to: '$year-12-31',
      );
      totalCount = yearlyExpenses.length;
      final analysis = {'totalAmount': totalAmount, 'count': totalCount};
      print('â ExpensesController: Yearly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error loading yearly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Obtener gastos por categorÃ­a
  Future<void> loadExpensesByCategory() async {
    _setLoading(true);
    try {
      print('ð ExpensesController: Loading expenses by category...');
      // Usando mÃ©todo existente para obtener gastos categorizados
      final expensesByCategory = await _service.getExpensesByCategoryBreakdown();
      print('â ExpensesController: Loaded expenses for ${expensesByCategory.length} categories');
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error loading expenses by category: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= BUDGET METHODS =============

  // ð Obtener gastos por presupuesto
  Future<void> loadExpensesByBudget(int budgetId) async {
    _setLoading(true);
    try {
      print('ð ExpensesController: Loading expenses for budget ID: $budgetId');
      final expensesByBudget = await _service.getExpensesByBudget(budgetId);
      print('â ExpensesController: Loaded ${expensesByBudget.length} expenses for budget');
      _setError(null);
    } catch (e) {
      print('â ExpensesController: Error loading expenses by budget: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Verificar lÃ­mite de presupuesto
  Future<bool> checkBudgetLimit(int budgetId, double amount) async {
    try {
      print('ð ExpensesController: Checking budget limit for budget ID: $budgetId, amount: $amount');
      final withinLimit = await _service.checkBudgetLimit(budgetId, amount);
      print('â ExpensesController: Budget limit check - Within limit: $withinLimit');
      return withinLimit;
    } catch (e) {
      print('â ExpensesController: Error checking budget limit: $e');
      return false;
    }
  }

  // ============= UTILITY METHODS =============

  // ð Limpiar datos
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

  // ð Obtener gasto por ID (desde la lista local)
  TransactionDetailDTO? getExpenseById(int id) {
    try {
      return expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  // ð Obtener gastos por categorÃ­a (desde la lista local)
  List<TransactionDetailDTO> getExpensesByCategory(int categoryId) {
    return expenses.where((expense) => expense.categoryId == categoryId).toList();
  }

  // ð Obtener gastos por rango de fechas (desde la lista local)
  List<TransactionDetailDTO> getExpensesByDateRange(DateTime from, DateTime to) {
    return expenses.where((expense) {
      final expenseDate = expense.transactionDate ?? DateTime.now();
      return expenseDate.isAfter(from.subtract(const Duration(days: 1))) &&
             expenseDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  // ð Obtener gastos por rango de monto (desde la lista local)
  List<TransactionDetailDTO> getExpensesByAmountRange(double minAmount, double maxAmount) {
    return expenses.where((expense) => 
        expense.amount >= minAmount && expense.amount <= maxAmount).toList();
  }

  // ð Verificar si hay gastos cargados
  bool get hasExpenses => expenses.isNotEmpty;

  // ð Obtener el mayor gasto
  TransactionDetailDTO? get highestExpense {
    if (expenses.isEmpty) return null;
    return expenses.reduce((current, next) => 
        current.amount > next.amount ? current : next);
  }

  // ð Obtener el menor gasto
  TransactionDetailDTO? get lowestExpense {
    if (expenses.isEmpty) return null;
    return expenses.reduce((current, next) => 
        current.amount < next.amount ? current : next);
  }

  // ð Obtener gastos recientes (Ãºltimos 30 dÃ­as)
  List<TransactionDetailDTO> get recentExpenses {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return expenses.where((expense) {
      final expenseDate = expense.transactionDate ?? DateTime.now();
      return expenseDate.isAfter(thirtyDaysAgo);
    }).toList();
  }

  // ð Obtener gastos por presupuesto (desde la lista local)
  List<TransactionDetailDTO> getExpensesByBudgetLocal(int budgetId) {
    return expenses.where((expense) => expense.budgetId == budgetId).toList();
  }

  // ð Calcular porcentaje del presupuesto usado
  double calculateBudgetUsagePercentage(int budgetId, double budgetLimit) {
    final budgetExpenses = getExpensesByBudgetLocal(budgetId);
    double totalSpent = 0.0;
    for (final expense in budgetExpenses) {
      totalSpent += expense.amount;
    }
    return budgetLimit > 0 ? (totalSpent / budgetLimit) * 100 : 0.0;
  }
}
