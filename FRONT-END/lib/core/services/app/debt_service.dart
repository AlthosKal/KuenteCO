import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import 'transaction_service.dart';

class DebtService {
  final TransactionService _transactionService;

  DebtService(this._transactionService);

  // ============= DEBT SPECIFIC METHODS =============

  // ✅ Get all debt transactions
  Future<List<TransactionDetailDTO>> getAllDebtTransactions() async {
    // In the backend, debt transactions would be filtered by debtId != null
    // For now, we'll use a generic filter
    return await _transactionService.getAllTransactions();
  }

  // ✅ Get debt transaction by ID
  Future<TransactionDetailDTO> getDebtTransactionById(int id) async {
    final transaction = await _transactionService.getTransactionById(id);
    // Note: In backend, we would validate that this is actually a debt transaction
    return transaction;
  }

  // ✅ Get debt transaction summary
  Future<List<TransactionSummaryDTO>> getDebtTransactionSummary() async {
    // Get all summaries and filter by debt transactions if needed
    final summaries = await _transactionService.getTransactionSummary();
    // Note: Backend should handle filtering for debt-related transactions
    return summaries;
  }

  // ✅ Get debt transactions by debt ID
  Future<List<TransactionDetailDTO>> getTransactionsByDebtId(int debtId) async {
    // This would filter transactions associated with a specific debt
    final allTransactions = await _transactionService.getAllTransactions();
    return allTransactions.where((t) => t.categoryId == debtId).toList(); // Placeholder logic
  }

  // ✅ Get debt transactions by profile
  Future<List<TransactionDetailDTO>> getDebtTransactionsByProfile(int profileId) async {
    return await _transactionService.getTransactionsWithFilters(
      profileId: profileId,
    );
  }

  // ✅ Get debt transactions by date range
  Future<List<TransactionDetailDTO>> getDebtTransactionsByDateRange({
    required String from,
    required String to,
  }) async {
    return await _transactionService.getTransactionsWithFilters(
      from: from,
      to: to,
    );
  }

  // ✅ Get debt transactions by amount range
  Future<List<TransactionDetailDTO>> getDebtTransactionsByAmountRange({
    double? minAmount,
    double? maxAmount,
  }) async {
    return await _transactionService.getTransactionsWithFilters(
      minAmount: minAmount,
      maxAmount: maxAmount,
    );
  }

  // ============= DEBT TRANSACTION CRUD OPERATIONS =============

  // ✅ Create debt payment transaction
  Future<TransactionDetailDTO> createDebtPayment(NewTransactionDTO dto) async {
    print('📌 DebtService: Creating debt payment transaction');
    return await _transactionService.addTransaction(dto);
  }

  // ✅ Create multiple debt payment transactions
  Future<List<TransactionDetailDTO>> createDebtPaymentsBatch(List<NewTransactionDTO> dtos) async {
    print('📌 DebtService: Creating ${dtos.length} debt payment transactions in batch');
    return await _transactionService.addTransactionsBatch(dtos);
  }

  // ✅ Update debt payment transaction
  Future<TransactionDetailDTO> updateDebtPayment(UpdateTransactionDTO dto) async {
    print('📌 DebtService: Updating debt payment transaction ID: ${dto.id}');
    return await _transactionService.updateTransaction(dto);
  }

  // ✅ Update multiple debt payment transactions
  Future<List<TransactionDetailDTO>> updateDebtPaymentsBatch(List<UpdateTransactionDTO> dtos) async {
    print('📌 DebtService: Updating ${dtos.length} debt payment transactions in batch');
    return await _transactionService.updateTransactionsBatch(dtos);
  }

  // ✅ Delete debt payment transaction
  Future<void> deleteDebtPayment(int id) async {
    print('📌 DebtService: Deleting debt payment transaction ID: $id');
    await _transactionService.deleteTransaction(id);
  }

  // ✅ Delete multiple debt payment transactions
  Future<void> deleteDebtPaymentsBatch(List<int> ids) async {
    print('📌 DebtService: Deleting ${ids.length} debt payment transactions in batch');
    await _transactionService.deleteTransactionsBatch(ids);
  }

  // ============= DEBT ANALYTICS =============

  // ✅ Get total debt payments amount
  Future<double> getTotalDebtPaymentsAmount() async {
    final debtPayments = await getAllDebtTransactions();
    double total = 0.0;
    for (final payment in debtPayments) {
      total += payment.amount;
    }
    return total;
  }

  // ✅ Get average debt payment amount
  Future<double> getAverageDebtPaymentAmount() async {
    final debtPayments = await getAllDebtTransactions();
    if (debtPayments.isEmpty) return 0.0;
    double total = 0.0;
    for (final payment in debtPayments) {
      total += payment.amount;
    }
    return total / debtPayments.length;
  }

  // ✅ Get debt payments count
  Future<int> getDebtPaymentsCount() async {
    final debtPayments = await getAllDebtTransactions();
    return debtPayments.length;
  }

  // ✅ Get monthly debt payments totals
  Future<Map<String, double>> getMonthlyDebtPaymentsTotals(int year) async {
    final from = '$year-01-01';
    final to = '$year-12-31';
    
    final debtPayments = await getDebtTransactionsByDateRange(from: from, to: to);
    
    final monthlyTotals = <String, double>{};
    
    for (final payment in debtPayments) {
      if (payment.transactionDate != null) {
        final monthKey = '${payment.transactionDate!.year}-${payment.transactionDate!.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + payment.amount;
      }
    }
    
    return monthlyTotals;
  }

  // ============= DEBT MANAGEMENT =============

  // ✅ Get debt payment history for specific debt
  Future<List<TransactionDetailDTO>> getDebtPaymentHistory(int debtId) async {
    return await getTransactionsByDebtId(debtId);
  }

  // ✅ Get total payments made for specific debt
  Future<double> getTotalPaymentsForDebt(int debtId) async {
    final payments = await getTransactionsByDebtId(debtId);
    double total = 0.0;
    for (final payment in payments) {
      total += payment.amount;
    }
    return total;
  }

  // ✅ Get largest debt payments
  Future<List<TransactionDetailDTO>> getLargestDebtPayments({int limit = 10}) async {
    final debtPayments = await getAllDebtTransactions();
    debtPayments.sort((a, b) => b.amount.compareTo(a.amount));
    
    return debtPayments.take(limit).toList();
  }

  // ✅ Get recent debt payments
  Future<List<TransactionDetailDTO>> getRecentDebtPayments({int limit = 10}) async {
    final debtPayments = await getAllDebtTransactions();
    
    // Sort by timestamp descending (most recent first)
    debtPayments.sort((a, b) {
      if (a.transactionDate == null && b.transactionDate == null) return 0;
      if (a.transactionDate == null) return 1;
      if (b.transactionDate == null) return -1;
      return b.transactionDate!.compareTo(a.transactionDate!);
    });
    
    return debtPayments.take(limit).toList();
  }

  // ✅ Get debt payments by debt breakdown
  Future<Map<String, List<TransactionDetailDTO>>> getDebtPaymentsByDebtBreakdown() async {
    final debtPayments = await getAllDebtTransactions();
    final debtBreakdown = <String, List<TransactionDetailDTO>>{};
    
    for (final payment in debtPayments) {
      final debtKey = payment.categoryId?.toString() ?? 'Unassigned'; // Placeholder logic
      debtBreakdown[debtKey] = debtBreakdown[debtKey] ?? [];
      debtBreakdown[debtKey]!.add(payment);
    }
    
    return debtBreakdown;
  }

  // ✅ Get payment frequency analysis
  Future<Map<String, int>> getPaymentFrequencyAnalysis() async {
    final debtPayments = await getAllDebtTransactions();
    final frequencyMap = <String, int>{};
    
    for (final payment in debtPayments) {
      if (payment.transactionDate != null) {
        final monthKey = '${payment.transactionDate!.year}-${payment.transactionDate!.month.toString().padLeft(2, '0')}';
        frequencyMap[monthKey] = (frequencyMap[monthKey] ?? 0) + 1;
      }
    }
    
    return frequencyMap;
  }

  // ✅ Get active debts (placeholder implementation)
  Future<List<TransactionDetailDTO>> getActiveDebts() async {
    // This is a placeholder - in a real app, this would filter by actual debt status
    print('📌 DebtService: Getting active debts...');
    final allDebts = await getAllDebtTransactions();
    // For now, return all debts as "active"
    return allDebts;
  }

  // ✅ Get overdue debts (placeholder implementation)
  Future<List<TransactionDetailDTO>> getOverdueDebts() async {
    // This is a placeholder - in a real app, this would check due dates
    print('📌 DebtService: Getting overdue debts...');
    final allDebts = await getAllDebtTransactions();
    // For now, return empty list as placeholder
    return [];
  }

  // ✅ Mark debt as paid (placeholder implementation)
  Future<void> markDebtAsPaid(int debtId) async {
    // This is a placeholder - in a real app, this would update debt status
    print('📌 DebtService: Marking debt ID $debtId as paid...');
    // This would typically involve updating a debt record in the backend
    // For now, we'll just log the action
  }

  // ✅ Get debts by due date (placeholder implementation)
  Future<List<TransactionDetailDTO>> getDebtsByDueDate(DateTime dueDate) async {
    // This is a placeholder - in a real app, this would filter by actual due dates
    print('📌 DebtService: Getting debts by due date: ${dueDate.toString()}...');
    final allDebts = await getAllDebtTransactions();
    // For now, filter by transaction date (timestamp)
    return allDebts.where((debt) {
      if (debt.transactionDate == null) return false;
      final debtDate = debt.transactionDate!;
      return debtDate.year == dueDate.year && 
             debtDate.month == dueDate.month && 
             debtDate.day == dueDate.day;
    }).toList();
  }
}
