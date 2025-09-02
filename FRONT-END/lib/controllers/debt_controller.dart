import 'package:flutter/material.dart';

import '../core/services/app/debt_service.dart';
import '../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../dto/app/transaction/kuenteco/update_transaction_dto.dart';

class DebtController extends ChangeNotifier {
  final DebtService _service;

  bool isLoading = false;
  String? errorMessage;

  List<TransactionDetailDTO> debts = [];
  List<TransactionSummaryDTO> debtSummaries = [];
  TransactionDetailDTO? currentDebt;
  
  // Estadísticas específicas de deudas
  double totalDebtAmount = 0.0;
  double averageDebtAmount = 0.0;
  int totalDebtCount = 0;

  DebtController(this._service);

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void _updateStatistics() {
    totalDebtCount = debts.length;
    double total = 0.0;
    for (final debt in debts) {
      total += debt.amount;
    }
    totalDebtAmount = total;
    averageDebtAmount = totalDebtCount > 0 ? totalDebtAmount / totalDebtCount : 0.0;
  }

  // ============= LOAD OPERATIONS =============

  // 📌 Cargar todas las deudas
  Future<void> loadDebts() async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading all debts from server...');
      debts = await _service.getAllDebtTransactions();
      print('✅ DebtController: Loaded ${debts.length} debts from server');
      
      // Log de todas las deudas para debug
      for (int i = 0; i < debts.length; i++) {
        print('   Debt $i: ID=${debts[i].id}, Name="${debts[i].name}", Amount=${debts[i].amount}');
      }
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading debts: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar deuda por ID
  Future<void> loadDebtById(int id) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading debt ID: $id');
      currentDebt = await _service.getDebtTransactionById(id);
      print('✅ DebtController: Loaded debt: ${currentDebt?.name}');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading debt: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar resumen de deudas
  Future<void> loadDebtSummaries() async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading debt summaries...');
      debtSummaries = await _service.getDebtTransactionSummary();
      print('✅ DebtController: Loaded ${debtSummaries.length} debt summaries');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading debt summaries: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar deudas filtradas
  Future<void> loadFilteredDebts({
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
      print('🔄 DebtController: Loading filtered debts...');
      // Usando métodos existentes del servicio según los filtros
      if (from != null && to != null) {
        debts = await _service.getDebtTransactionsByDateRange(from: from, to: to);
      } else if (minAmount != null || maxAmount != null) {
        debts = await _service.getDebtTransactionsByAmountRange(
          minAmount: minAmount,
          maxAmount: maxAmount,
        );
      } else if (profileId != null) {
        debts = await _service.getDebtTransactionsByProfile(profileId);
      } else {
        debts = await _service.getAllDebtTransactions();
      }
      print('✅ DebtController: Loaded ${debts.length} filtered debts');
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading filtered debts: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // 📌 Crear deuda
  Future<void> addDebt(NewTransactionDTO dto) async {
    _setError(null);
    
    try {
      print('📌 DebtController: Creating debt...');
      final createdDebt = await _service.createDebtPayment(dto);
      print('✅ DebtController: Debt created with ID: ${createdDebt.id}');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error creating debt: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Crear múltiples deudas (batch)
  Future<void> addDebtsBatch(List<NewTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 DebtController: Creating ${dtos.length} debts in batch...');
      final createdDebts = await _service.createDebtPaymentsBatch(dtos);
      print('✅ DebtController: Batch creation completed. Created ${createdDebts.length} debts');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error in batch creation: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar deuda
  Future<void> updateDebt(UpdateTransactionDTO dto) async {
    print('🔄 DebtController: Starting update for debt ID: ${dto.id}');
    
    _setError(null);
    
    try {
      print('🔄 DebtController: Calling service.updateDebt...');
      final updatedDebt = await _service.updateDebtPayment(dto);
      print('✅ DebtController: Debt updated successfully: ${updatedDebt.name}');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error during update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar múltiples deudas (batch)
  Future<void> updateDebtsBatch(List<UpdateTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 DebtController: Updating ${dtos.length} debts in batch...');
      final updatedDebts = await _service.updateDebtPaymentsBatch(dtos);
      print('✅ DebtController: Batch update completed. Updated ${updatedDebts.length} debts');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error in batch update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Eliminar deuda
  Future<void> deleteDebt(int id) async {
    _setLoading(true);
    try {
      print('📌 DebtController: Deleting debt ID: $id');
      await _service.deleteDebtPayment(id);
      print('✅ DebtController: Debt deleted successfully');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error deleting debt: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Eliminar múltiples deudas (batch)
  Future<void> deleteDebtsBatch(List<int> ids) async {
    _setError(null);
    
    try {
      print('📌 DebtController: Deleting ${ids.length} debts in batch...');
      await _service.deleteDebtPaymentsBatch(ids);
      print('✅ DebtController: Batch deletion completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error in batch deletion: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= ANALYSIS METHODS =============

  // 📌 Obtener análisis mensual de deudas
  Future<void> loadMonthlyDebtAnalysis(int year, int month) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading monthly debt analysis for $year-$month...');
      // Implementando análisis mensual usando datos existentes
      final from = '$year-${month.toString().padLeft(2, '0')}-01';
      final to = '$year-${month.toString().padLeft(2, '0')}-31';
      final monthlyDebts = await _service.getDebtTransactionsByDateRange(from: from, to: to);
      double total = 0.0;
      for (final debt in monthlyDebts) {
        total += debt.amount;
      }
      final analysis = {'totalAmount': total, 'count': monthlyDebts.length};
      print('✅ DebtController: Monthly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading monthly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener análisis anual de deudas
  Future<void> loadYearlyDebtAnalysis(int year) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading yearly debt analysis for $year...');
      // Implementando análisis anual usando datos existentes
      final monthlyTotals = await _service.getMonthlyDebtPaymentsTotals(year);
      double totalAmount = 0.0;
      for (final monthTotal in monthlyTotals.values) {
        totalAmount += monthTotal;
      }
      // Obtener el conteo total del año
      final yearlyDebts = await _service.getDebtTransactionsByDateRange(
        from: '$year-01-01', 
        to: '$year-12-31',
      );
      final totalCount = yearlyDebts.length;
      final analysis = {'totalAmount': totalAmount, 'count': totalCount};
      print('✅ DebtController: Yearly analysis loaded - Total: ${analysis['totalAmount']}, Count: ${analysis['count']}');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading yearly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener deudas por categoría
  Future<void> loadDebtsByCategory() async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading debts by category...');
      // Usando método existente para obtener deudas categorizadas
      final debtsByCategory = await _service.getDebtPaymentsByDebtBreakdown();
      print('✅ DebtController: Loaded debts for ${debtsByCategory.length} categories');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading debts by category: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= DEBT SPECIFIC METHODS =============

  // 📌 Obtener deudas activas (no pagadas)
  Future<void> loadActiveDebts() async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading active debts...');
      final activeDebts = await _service.getActiveDebts();
      print('✅ DebtController: Loaded ${activeDebts.length} active debts');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading active debts: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener deudas vencidas
  Future<void> loadOverdueDebts() async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading overdue debts...');
      final overdueDebts = await _service.getOverdueDebts();
      print('✅ DebtController: Loaded ${overdueDebts.length} overdue debts');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading overdue debts: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Marcar deuda como pagada
  Future<void> markDebtAsPaid(int debtId) async {
    try {
      print('📌 DebtController: Marking debt ID $debtId as paid...');
      await _service.markDebtAsPaid(debtId);
      print('✅ DebtController: Debt marked as paid successfully');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error marking debt as paid: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Calcular total de deudas por fecha de vencimiento
  Future<void> loadDebtsByDueDate(DateTime dueDate) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading debts by due date: ${dueDate.toString()}...');
      final debtsByDueDate = await _service.getDebtsByDueDate(dueDate);
      print('✅ DebtController: Loaded ${debtsByDueDate.length} debts for due date');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading debts by due date: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= UTILITY METHODS =============

  // 📌 Limpiar datos
  void clearData() {
    debts.clear();
    debtSummaries.clear();
    currentDebt = null;
    totalDebtAmount = 0.0;
    averageDebtAmount = 0.0;
    totalDebtCount = 0;
    _setError(null);
    notifyListeners();
  }

  // 📌 Obtener deuda por ID (desde la lista local)
  TransactionDetailDTO? getDebtById(int id) {
    try {
      return debts.firstWhere((debt) => debt.id == id);
    } catch (e) {
      return null;
    }
  }

  // 📌 Obtener deudas por categoría (desde la lista local)
  List<TransactionDetailDTO> getDebtsByCategory(int categoryId) {
    return debts.where((debt) => debt.categoryId == categoryId).toList();
  }

  // 📌 Obtener deudas por rango de fechas (desde la lista local)
  List<TransactionDetailDTO> getDebtsByDateRange(DateTime from, DateTime to) {
    return debts.where((debt) {
      final debtDate = debt.transactionDate ?? DateTime.now();
      return debtDate.isAfter(from.subtract(const Duration(days: 1))) &&
             debtDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  // 📌 Obtener deudas por rango de monto (desde la lista local)
  List<TransactionDetailDTO> getDebtsByAmountRange(double minAmount, double maxAmount) {
    return debts.where((debt) => 
        debt.amount >= minAmount && debt.amount <= maxAmount).toList();
  }

  // 📌 Verificar si hay deudas cargadas
  bool get hasDebts => debts.isNotEmpty;

  // 📌 Obtener la mayor deuda
  TransactionDetailDTO? get highestDebt {
    if (debts.isEmpty) return null;
    return debts.reduce((current, next) => 
        current.amount > next.amount ? current : next);
  }

  // 📌 Obtener la menor deuda
  TransactionDetailDTO? get lowestDebt {
    if (debts.isEmpty) return null;
    return debts.reduce((current, next) => 
        current.amount < next.amount ? current : next);
  }

  // 📌 Obtener deudas recientes (últimos 30 días)
  List<TransactionDetailDTO> get recentDebts {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return debts.where((debt) {
      final debtDate = debt.transactionDate ?? DateTime.now();
      return debtDate.isAfter(thirtyDaysAgo);
    }).toList();
  }

  // 📌 Obtener deudas activas (desde la lista local - asumiendo que hay un campo isPaid)
  List<TransactionDetailDTO> get activeDebtsLocal {
    // Nota: Esto asume que existe un campo 'isPaid' o similar en TransactionDetailDTO
    // Si no existe, se podría usar otro criterio como fecha de vencimiento
    return debts.where((debt) => 
        debt.description?.toLowerCase().contains('activa') == true ||
        debt.description?.toLowerCase().contains('pendiente') == true).toList();
  }

  // 📌 Obtener deudas por prioridad (ordenadas por monto descendente)
  List<TransactionDetailDTO> get debtsByPriority {
    List<TransactionDetailDTO> sortedDebts = List.from(debts);
    sortedDebts.sort((a, b) => b.amount.compareTo(a.amount));
    return sortedDebts;
  }

  // 📌 Obtener resumen de estado de deudas
  Map<String, dynamic> get debtStatusSummary {
    return {
      'totalCount': totalDebtCount,
      'totalAmount': totalDebtAmount,
      'averageAmount': averageDebtAmount,
      'activeDebts': activeDebtsLocal.length,
      'recentDebts': recentDebts.length,
    };
  }
}
