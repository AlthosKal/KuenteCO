import 'package:flutter/material.dart';

import '../core/services/app/debt_service.dart';
import '../dto/app/debt/new_debt_dto.dart';
import '../dto/app/debt/debt_dto.dart';
import '../dto/app/debt/debt_payment_dto.dart';
import '../dto/app/debt/debt_summary_dto.dart';
import '../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../utils/enum/state_debt_enum.dart';

class DebtController extends ChangeNotifier {
  final DebtService _service;

  bool isLoading = false;
  String? errorMessage;

  List<DebtDTO> debts = [];
  DebtSummaryDTO? debtSummary;
  DebtDTO? currentDebt;
  
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
      total += debt.totalAmount.toDouble();
    }
    totalDebtAmount = total;
    averageDebtAmount = totalDebtCount > 0 ? totalDebtAmount / totalDebtCount : 0.0;
  }

  // ============= LOAD OPERATIONS =============

  // 📌 Cargar todas las deudas
  Future<void> loadDebts({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading all debts from server...');
      debts = await _service.getAllDebts(from: from, to: to, kind: kind);
      print('✅ DebtController: Loaded ${debts.length} debts from server');
      
      // Log de todas las deudas para debug
      for (int i = 0; i < debts.length; i++) {
        print('   Debt $i: ID=${debts[i].id}, Name="${debts[i].name}", Total=${debts[i].totalAmount}, Pending=${debts[i].pendingAmount}, State=${debts[i].state}');
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

  // 📌 Cargar deudas por estado
  Future<void> loadDebtsByState(StateDebt state, {String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading debts by state: $state');
      debts = await _service.getDebtsByState(state, from: from, to: to, kind: kind);
      print('✅ DebtController: Loaded ${debts.length} debts with state: $state');
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading debts by state: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar resumen de deudas
  Future<void> loadDebtSummary({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading debt summary...');
      debtSummary = await _service.getDebtSummaryReport(from: from, to: to, kind: kind);
      print('✅ DebtController: Loaded debt summary with ${debtSummary?.totalDebts} total debts');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading debt summary: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar deudas vencidas
  Future<void> loadOverdueDebts({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading overdue debts...');
      debts = await _service.getOverdueDebts(from: from, to: to, kind: kind);
      print('✅ DebtController: Loaded ${debts.length} overdue debts');
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading overdue debts: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar deudas próximas a vencer
  Future<void> loadDebtsExpiringSoon(int days, {String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading debts expiring in $days days...');
      debts = await _service.getDebtsExpiringInDays(days, from: from, to: to, kind: kind);
      print('✅ DebtController: Loaded ${debts.length} debts expiring soon');
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading expiring debts: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener total pendiente
  Future<void> loadTotalPendingAmount({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading total pending amount...');
      final totalPending = await _service.getTotalPendingAmount(from: from, to: to, kind: kind);
      totalDebtAmount = totalPending;
      print('✅ DebtController: Total pending amount: \$${totalPending.toStringAsFixed(2)}');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading total pending: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // 📌 Crear deuda
  Future<void> addDebt(NewDebtDTO dto) async {
    _setError(null);
    
    try {
      print('📌 DebtController: Creating debt...');
      final createdDebt = await _service.createDebt(dto);
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
  Future<void> addDebtsBatch(List<NewDebtDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 DebtController: Creating ${dtos.length} debts in batch...');
      final createdDebts = await _service.createDebtsBatch(dtos);
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
  Future<void> updateDebt(DebtDTO dto) async {
    print('🔄 DebtController: Starting update for debt ID: ${dto.id}');
    
    _setError(null);
    
    try {
      print('🔄 DebtController: Calling service.updateDebt...');
      final updatedDebt = await _service.updateDebt(dto);
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
  Future<void> updateDebtsBatch(List<DebtDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 DebtController: Updating ${dtos.length} debts in batch...');
      final updatedDebts = await _service.updateDebtsBatch(dtos);
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
      await _service.deleteDebt(id);
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
      await _service.deleteDebtsBatch(ids);
      print('✅ DebtController: Batch deletion completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error in batch deletion: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= NEW DEBT SPECIFIC METHODS =============

  // 📌 Realizar pago de deuda
  Future<void> makeDebtPayment(DebtPaymentDTO dto) async {
    _setError(null);
    
    try {
      print('💰 DebtController: Making payment to debt ID: ${dto.debtId}');
      final paymentResult = await _service.makePayment(dto);
      print('✅ DebtController: Payment made successfully: $paymentResult');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error making payment: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar estado de deuda
  Future<void> updateDebtState(int id, StateDebt state) async {
    _setError(null);
    
    try {
      print('🔄 DebtController: Updating debt state for ID: $id to $state');
      final result = await _service.updateDebtState(id, state);
      print('✅ DebtController: Debt state updated successfully: $result');
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      print('❌ DebtController: Error updating debt state: $e');
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
      final from = '$year-${month.toString().padLeft(2, '0')}-01';
      final to = '$year-${month.toString().padLeft(2, '0')}-31';
      final monthlyDebts = await _service.getAllDebts(from: from, to: to);
      double total = 0.0;
      for (final debt in monthlyDebts) {
        total += debt.totalAmount.toDouble();
      }
      print('✅ DebtController: Monthly analysis loaded - Total: \$${total.toStringAsFixed(2)}, Count: ${monthlyDebts.length}');
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
      final from = '$year-01-01';
      final to = '$year-12-31';
      final yearlyDebts = await _service.getAllDebts(from: from, to: to);
      double totalAmount = 0.0;
      for (final debt in yearlyDebts) {
        totalAmount += debt.totalAmount.toDouble();
      }
      print('✅ DebtController: Yearly analysis loaded - Total: \$${totalAmount.toStringAsFixed(2)}, Count: ${yearlyDebts.length}');
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading yearly analysis: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Obtener deudas activas
  Future<void> loadActiveDebts() async {
    await loadDebtsByState(StateDebt.ACTIVE);
  }

  // 📌 Cargar deudas activas usando el nuevo método
  Future<void> loadActiveDebtsNew() async {
    _setLoading(true);
    try {
      print('🔄 DebtController: Loading active debts...');
      debts = await _service.getActiveDebts();
      print('✅ DebtController: Loaded ${debts.length} active debts');
      _updateStatistics();
      _setError(null);
    } catch (e) {
      print('❌ DebtController: Error loading active debts: $e');
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
      // Usar loadDebtsExpiringSoon para obtener deudas próximas a vencer
      final daysDifference = dueDate.difference(DateTime.now()).inDays;
      if (daysDifference > 0) {
        await loadDebtsExpiringSoon(daysDifference);
      } else {
        await loadOverdueDebts();
      }
      print('✅ DebtController: Loaded debts for due date');
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
    debtSummary = null;
    currentDebt = null;
    totalDebtAmount = 0.0;
    averageDebtAmount = 0.0;
    totalDebtCount = 0;
    _setError(null);
    notifyListeners();
  }

  // 📌 Obtener deuda por ID (desde la lista local)
  DebtDTO? getDebtById(int id) {
    try {
      return debts.firstWhere((debt) => debt.id == id);
    } catch (e) {
      return null;
    }
  }

  // 📌 Obtener deudas por estado (desde la lista local)
  List<DebtDTO> getDebtsByStateLocal(StateDebt state) {
    return debts.where((debt) => debt.state == state).toList();
  }

  // 📌 Obtener deudas por rango de fechas (desde la lista local)
  List<DebtDTO> getDebtsByDateRangeLocal(DateTime from, DateTime to) {
    return debts.where((debt) {
      final debtStartDate = debt.startDate;
      return debtStartDate.isAfter(from.subtract(const Duration(days: 1))) &&
             debtStartDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  // 📌 Obtener deudas por rango de monto (desde la lista local)
  List<DebtDTO> getDebtsByAmountRangeLocal(double minAmount, double maxAmount) {
    return debts.where((debt) => 
        debt.totalAmount.toDouble() >= minAmount && 
        debt.totalAmount.toDouble() <= maxAmount).toList();
  }

  // 📌 Verificar si hay deudas cargadas
  bool get hasDebts => debts.isNotEmpty;

  // 📌 Obtener la mayor deuda
  DebtDTO? get highestDebt {
    if (debts.isEmpty) return null;
    return debts.reduce((current, next) => 
        current.totalAmount > next.totalAmount ? current : next);
  }

  // 📌 Obtener la menor deuda
  DebtDTO? get lowestDebt {
    if (debts.isEmpty) return null;
    return debts.reduce((current, next) => 
        current.totalAmount < next.totalAmount ? current : next);
  }

  // 📌 Obtener deudas recientes (últimos 30 días)
  List<DebtDTO> get recentDebts {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return debts.where((debt) {
      return debt.startDate.isAfter(thirtyDaysAgo);
    }).toList();
  }

  // 📌 Obtener deudas activas (desde la lista local)
  List<DebtDTO> get activeDebtsLocal {
    return debts.where((debt) => debt.state == StateDebt.ACTIVE).toList();
  }

  // 📌 Obtener deudas vencidas (desde la lista local)  
  List<DebtDTO> get overdueDebtsLocal {
    return debts.where((debt) => debt.state == StateDebt.DEFEATED).toList();
  }

  // 📌 Obtener deudas pagadas (desde la lista local)
  List<DebtDTO> get paidDebtsLocal {
    return debts.where((debt) => debt.state == StateDebt.PAID).toList();
  }

  // 📌 Obtener deudas por prioridad (ordenadas por monto pendiente descendente)
  List<DebtDTO> get debtsByPriority {
    List<DebtDTO> sortedDebts = List.from(debts);
    sortedDebts.sort((a, b) => b.pendingAmount.compareTo(a.pendingAmount));
    return sortedDebts;
  }

  // 📌 Obtener resumen de estado de deudas
  Map<String, dynamic> get debtStatusSummary {
    return {
      'totalCount': totalDebtCount,
      'totalAmount': totalDebtAmount,
      'averageAmount': averageDebtAmount,
      'activeDebts': activeDebtsLocal.length,
      'overdueDebts': overdueDebtsLocal.length,
      'paidDebts': paidDebtsLocal.length,
      'recentDebts': recentDebts.length,
      'highestDebt': highestDebt?.totalAmount.toDouble() ?? 0.0,
      'lowestDebt': lowestDebt?.totalAmount.toDouble() ?? 0.0,
    };
  }

  // ============= MULTIPLE OPERATION METHODS =============

  // 📌 Crear múltiples deudas
  Future<void> addMultipleDebts(List<NewDebtDTO> dtos) async {
    await addDebtsBatch(dtos);
  }

  // 📌 Actualizar múltiples deudas  
  Future<void> updateMultipleDebts(List<DebtDTO> dtos) async {
    await updateDebtsBatch(dtos);
  }

  // 📌 Eliminar múltiples deudas
  Future<void> deleteMultipleDebts(List<int> ids) async {
    await deleteDebtsBatch(ids);
  }
}
