import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import 'transaction_service.dart';

class ExpensesService {
  final TransactionService _transactionService;

  ExpensesService(this._transactionService);

  // ============= EXPENSES SPECIFIC METHODS =============

  // â Get all expense transactions
  Future<List<TransactionDetailDTO>> getAllExpenses() async {
    return await _transactionService.getTransactionsWithFilters(
      type: 'EXPENSE',
    );
  }

  // â Get expense by ID
  Future<TransactionDetailDTO> getExpenseById(int id) async {
    final transaction = await _transactionService.getTransactionById(id);
    // Note: In backend, we would validate that this is actually an expense
    return transaction;
  }

  // â Get expense summary
  Future<List<TransactionSummaryDTO>> getExpenseSummary() async {
    // Get all summaries and filter by expense type if needed
    final summaries = await _transactionService.getTransactionSummary();
    // Note: Backend should handle filtering, but we can do client-side filtering if needed
    return summaries;
  }

  // â Get expenses by category
  Future<List<TransactionDetailDTO>> getExpensesByCategory(int categoryId) async {
    return await _transactionService.getTransactionsWithFilters(
      categoryId: categoryId,
      type: 'EXPENSE',
    );
  }

  // â Get expenses by budget
  Future<List<TransactionDetailDTO>> getExpensesByBudget(int budgetId) async {
    return await _transactionService.getTransactionsWithFilters(
      budgetId: budgetId,
      type: 'EXPENSE',
    );
  }

  // â Get expenses by profile
  Future<List<TransactionDetailDTO>> getExpensesByProfile(int profileId) async {
    return await _transactionService.getTransactionsWithFilters(
      profileId: profileId,
      type: 'EXPENSE',
    );
  }

  // â Get expenses by date range
  Future<List<TransactionDetailDTO>> getExpensesByDateRange({
    required String from,
    required String to,
  }) async {
    return await _transactionService.getTransactionsWithFilters(
      from: from,
      to: to,
      type: 'EXPENSE',
    );
  }

  // â Get expenses by amount range
  Future<List<TransactionDetailDTO>> getExpensesByAmountRange({
    double? minAmount,
    double? maxAmount,
  }) async {
    return await _transactionService.getTransactionsWithFilters(
      minAmount: minAmount,
      maxAmount: maxAmount,
      type: 'EXPENSE',
    );
  }

  // ============= EXPENSES CRUD OPERATIONS =============

  // â Create new expense
  Future<TransactionDetailDTO> createExpense(NewTransactionDTO dto) async {
    print('ð ExpensesService: Creating expense transaction');
    return await _transactionService.addTransaction(dto);
  }

  // â Create multiple expenses
  Future<List<TransactionDetailDTO>> createExpensesBatch(List<NewTransactionDTO> dtos) async {
    print('ð ExpensesService: Creating ${dtos.length} expense transactions in batch');
    return await _transactionService.addTransactionsBatch(dtos);
  }

  // â Update expense
  Future<TransactionDetailDTO> updateExpense(UpdateTransactionDTO dto) async {
    print('ð ExpensesService: Updating expense transaction ID: ${dto.id}');
    return await _transactionService.updateTransaction(dto);
  }

  // â Update multiple expenses
  Future<List<TransactionDetailDTO>> updateExpensesBatch(List<UpdateTransactionDTO> dtos) async {
    print('ð ExpensesService: Updating ${dtos.length} expense transactions in batch');
    return await _transactionService.updateTransactionsBatch(dtos);
  }

  // â Delete expense
  Future<void> deleteExpense(int id) async {
    print('ð ExpensesService: Deleting expense transaction ID: $id');
    await _transactionService.deleteTransaction(id);
  }

  // â Delete multiple expenses
  Future<void> deleteExpensesBatch(List<int> ids) async {
    print('ð ExpensesService: Deleting ${ids.length} expense transactions in batch');
    await _transactionService.deleteTransactionsBatch(ids);
  }

  // ============= EXPENSES ANALYTICS =============

  // â Get total expense amount
  Future<double> getTotalExpenseAmount() async {
    final expenses = await getAllExpenses();
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  // â Get average expense amount
  Future<double> getAverageExpenseAmount() async {
    final expenses = await getAllExpenses();
    if (expenses.isEmpty) return 0.0;
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total / expenses.length;
  }

  // â Get expense count
  Future<int> getExpenseCount() async {
    final expenses = await getAllExpenses();
    return expenses.length;
  }

  // â Get monthly expense totals
  Future<Map<String, double>> getMonthlyExpenseTotals(int year) async {
    final from = '$year-01-01';
    final to = '$year-12-31';
    
    final expenses = await getExpensesByDateRange(from: from, to: to);
    
    final monthlyTotals = <String, double>{};
    
    for (final expense in expenses) {
      if (expense.transactionDate != null) {
        final monthKey = '${expense.transactionDate!.year}-${expense.transactionDate!.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + expense.amount;
      }
    }
    
    return monthlyTotals;
  }

  // ============= EXPENSES CATEGORIZATION =============

  // â Get top spending categories
  Future<Map<String, double>> getTopSpendingCategories({int limit = 10}) async {
    final expenses = await getAllExpenses();
    final categoryTotals = <String, double>{};
    
    for (final expense in expenses) {
      if (expense.categoryId != null) {
        // Note: In a real implementation, you would get category name from the category ID
        final categoryKey = 'Category ${expense.categoryId}';
        categoryTotals[categoryKey] = (categoryTotals[categoryKey] ?? 0.0) + expense.amount;
      }
    }
    
    // Sort by amount and take top entries
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final result = <String, double>{};
    for (int i = 0; i < sortedEntries.length && i < limit; i++) {
      result[sortedEntries[i].key] = sortedEntries[i].value;
    }
    
    return result;
  }

  // â Get expenses by category breakdown
  Future<Map<String, List<TransactionDetailDTO>>> getExpensesByCategoryBreakdown() async {
    final expenses = await getAllExpenses();
    final categoryBreakdown = <String, List<TransactionDetailDTO>>{};
    
    for (final expense in expenses) {
      final categoryKey = expense.categoryId?.toString() ?? 'Uncategorized';
      categoryBreakdown[categoryKey] = categoryBreakdown[categoryKey] ?? [];
      categoryBreakdown[categoryKey]!.add(expense);
    }
    
    return categoryBreakdown;
  }

  // â Get largest single expenses
  Future<List<TransactionDetailDTO>> getLargestExpenses({int limit = 10}) async {
    final expenses = await getAllExpenses();
    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    
    return expenses.take(limit).toList();
  }

  // â Check budget limit (placeholder implementation)
  Future<bool> checkBudgetLimit(int budgetId, double amount) async {
    // This is a placeholder implementation
    // In a real app, this would check against actual budget limits from the backend
    print('ð ExpensesService: Checking budget limit for budget ID: $budgetId, amount: $amount');
    
    // For now, we'll assume a basic check: if the current expenses + new amount exceed a threshold
    final budgetExpenses = await getExpensesByBudget(budgetId);
    double currentTotal = 0.0;
    for (final expense in budgetExpenses) {
      currentTotal += expense.amount;
    }
    
    // Placeholder logic: assume budget limit is 10000 for all budgets
    const double defaultBudgetLimit = 10000.0;
    final newTotal = currentTotal + amount;
    
    return newTotal <= defaultBudgetLimit;
  }
}
