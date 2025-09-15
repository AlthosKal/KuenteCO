import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import 'transaction_service.dart';

class IncomeService {
  final TransactionService _transactionService;

  IncomeService(this._transactionService);

  // ============= INCOME SPECIFIC METHODS =============

  // â Get all income transactions
  Future<List<TransactionDetailDTO>> getAllIncomes() async {
    return _transactionService.getTransactionsWithFilters(
      type: 'INCOME',
    );
  }

  // â Get income by ID
  Future<TransactionDetailDTO> getIncomeById(int id) async {
    final transaction = await _transactionService.getTransactionById(id);
    // Note: In backend, we would validate that this is actually an income
    return transaction;
  }

  // â Get income summary
  Future<List<TransactionSummaryDTO>> getIncomeSummary() async {
    // Get all summaries and filter by income type if needed
    final summaries = await _transactionService.getTransactionSummary();
    // Note: Backend should handle filtering, but we can do client-side filtering if needed
    return summaries;
  }

  // â Get incomes by category
  Future<List<TransactionDetailDTO>> getIncomesByCategory(int categoryId) async {
    return _transactionService.getTransactionsWithFilters(
      categoryId: categoryId,
      type: 'INCOME',
    );
  }

  // â Get incomes by budget
  Future<List<TransactionDetailDTO>> getIncomesByBudget(int budgetId) async {
    return _transactionService.getTransactionsWithFilters(
      budgetId: budgetId,
      type: 'INCOME',
    );
  }

  // â Get incomes by profile
  Future<List<TransactionDetailDTO>> getIncomesByProfile(int profileId) async {
    return _transactionService.getTransactionsWithFilters(
      profileId: profileId,
      type: 'INCOME',
    );
  }

  // â Get incomes by date range
  Future<List<TransactionDetailDTO>> getIncomesByDateRange({
    required String from,
    required String to,
  }) async {
    return _transactionService.getTransactionsWithFilters(
      from: from,
      to: to,
      type: 'INCOME',
    );
  }

  // â Get incomes by amount range
  Future<List<TransactionDetailDTO>> getIncomesByAmountRange({
    double? minAmount,
    double? maxAmount,
  }) async {
    return _transactionService.getTransactionsWithFilters(
      minAmount: minAmount,
      maxAmount: maxAmount,
      type: 'INCOME',
    );
  }

  // ============= INCOME CRUD OPERATIONS =============

  // â Create new income
  Future<TransactionDetailDTO> addIncome(NewTransactionDTO dto) async {
    print('ð IncomeService: Creating income transaction');
    return _transactionService.addTransaction(dto);
  }

  // â Create multiple incomes
  Future<List<TransactionDetailDTO>> addIncomesBatch(List<NewTransactionDTO> dtos) async {
    print('ð IncomeService: Creating ${dtos.length} income transactions in batch');
    return _transactionService.addTransactionsBatch(dtos);
  }

  // â Update income
  Future<TransactionDetailDTO> updateIncome(UpdateTransactionDTO dto) async {
    print('ð IncomeService: Updating income transaction ID: ${dto.id}');
    return _transactionService.updateTransaction(dto);
  }

  // â Update multiple incomes
  Future<List<TransactionDetailDTO>> updateIncomesBatch(List<UpdateTransactionDTO> dtos) async {
    print('ð IncomeService: Updating ${dtos.length} income transactions in batch');
    return _transactionService.updateTransactionsBatch(dtos);
  }

  // â Delete income
  Future<void> deleteIncome(int id) async {
    print('ð IncomeService: Deleting income transaction ID: $id');
    await _transactionService.deleteTransaction(id);
  }

  // â Delete multiple incomes
  Future<void> deleteIncomesBatch(List<int> ids) async {
    print('ð IncomeService: Deleting ${ids.length} income transactions in batch');
    await _transactionService.deleteTransactionsBatch(ids);
  }

  // ============= INCOME ANALYTICS =============

  // â Get total income amount
  Future<double> getTotalIncomeAmount() async {
    final incomes = await getAllIncomes();
    double total = 0.0;
    for (final income in incomes) {
      total += income.amount;
    }
    return total;
  }

  // â Get average income amount
  Future<double> getAverageIncomeAmount() async {
    final incomes = await getAllIncomes();
    if (incomes.isEmpty) return 0.0;
    double total = 0.0;
    for (final income in incomes) {
      total += income.amount;
    }
    return total / incomes.length;
  }

  // â Get income count
  Future<int> getIncomeCount() async {
    final incomes = await getAllIncomes();
    return incomes.length;
  }

  // â Get monthly income totals
  Future<Map<String, double>> getMonthlyIncomeTotals(int year) async {
    final from = '$year-01-01';
    final to = '$year-12-31';
    
    final incomes = await getIncomesByDateRange(from: from, to: to);
    
    final monthlyTotals = <String, double>{};
    
    for (final income in incomes) {
      if (income.transactionDate != null) {
        final monthKey = '${income.transactionDate!.year}-${income.transactionDate!.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + income.amount;
      }
    }
    
    return monthlyTotals;
  }

  // â Get monthly income analysis
  Future<Map<String, dynamic>> getMonthlyIncomeAnalysis(int year, int month) async {
    final from = '$year-${month.toString().padLeft(2, '0')}-01';
    final to = '$year-${month.toString().padLeft(2, '0')}-31';
    
    final incomes = await getIncomesByDateRange(from: from, to: to);
    
    double totalAmount = 0.0;
    for (final income in incomes) {
      totalAmount += income.amount;
    }
    
    return {
      'totalAmount': totalAmount,
      'count': incomes.length,
      'averageAmount': incomes.isNotEmpty ? totalAmount / incomes.length : 0.0,
      'transactions': incomes,
    };
  }

  // â Get yearly income analysis
  Future<Map<String, dynamic>> getYearlyIncomeAnalysis(int year) async {
    final from = '$year-01-01';
    final to = '$year-12-31';
    
    final incomes = await getIncomesByDateRange(from: from, to: to);
    final monthlyBreakdown = await getMonthlyIncomeTotals(year);
    
    double totalAmount = 0.0;
    for (final income in incomes) {
      totalAmount += income.amount;
    }
    
    return {
      'totalAmount': totalAmount,
      'count': incomes.length,
      'averageAmount': incomes.isNotEmpty ? totalAmount / incomes.length : 0.0,
      'monthlyBreakdown': monthlyBreakdown,
      'transactions': incomes,
    };
  }

  // â Get filtered incomes
  Future<List<TransactionDetailDTO>> getFilteredIncomes({
    int? categoryId,
    int? budgetId,
    int? profileId,
    String? from,
    String? to,
    double? minAmount,
    double? maxAmount,
  }) async {
    return _transactionService.getTransactionsWithFilters(
      categoryId: categoryId,
      budgetId: budgetId,
      profileId: profileId,
      from: from,
      to: to,
      minAmount: minAmount,
      maxAmount: maxAmount,
      type: 'INCOME',
    );
  }
}
