import 'package:flutter/material.dart';

import '../../core/services/app/debt_service.dart';
import '../../dto/app/debt/new_debt_dto.dart';
import '../../dto/app/debt/debt_dto.dart';
import '../../dto/app/debt/debt_enrollment_dto.dart';
import '../../dto/app/debt/debt_payment_dto.dart';
import '../../dto/app/debt/debt_summary_dto.dart';
import '../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../utils/enum/state_debt_enum.dart';

class DebtController extends ChangeNotifier {
  final DebtService _service;

  bool isLoading = false;
  String? errorMessage;

  List<DebtDTO> debts = [];
  List<DebtEnrollmentDTO> enrollments = [];
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

  // ð Cargar todas las deudas
  Future<void> loadDebts({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      
      // Try to get all debts first (for USER role)
      try {
        debts = await _service.getAllDebts(from: from, to: to, kind: kind);
      } catch (e) {
        // If fails due to role restrictions, try assigned debts (for PROFILE role)
        if (e.toString().contains('solo disponible para usuarios') || 
            e.toString().contains('400')) {
          debts = await _service.getAssignedDebts(from: from, to: to, kind: kind);
        } else {
          rethrow;
        }
      }
      
      // Log de todas las deudas para debug
      for (int i = 0; i < debts.length; i++) {
        print('   Debt $i: ID=${debts[i].id}, Name="${debts[i].name}", Total=${debts[i].totalAmount}, Pending=${debts[i].pendingAmount}, State=${debts[i].state}');
      }
      
      _updateStatistics();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar deudas por estado
  Future<void> loadDebtsByState(StateDebt state, {String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      debts = await _service.getDebtsByState(state, from: from, to: to, kind: kind);
      _updateStatistics();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar resumen de deudas
  Future<void> loadDebtSummary({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      debtSummary = await _service.getDebtSummaryReport(from: from, to: to, kind: kind);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar deudas vencidas
  Future<void> loadOverdueDebts({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      debts = await _service.getOverdueDebts(from: from, to: to, kind: kind);
      _updateStatistics();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar deudas próximas a vencer
  Future<void> loadDebtsExpiringSoon(int days, {String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      debts = await _service.getDebtsExpiringInDays(days, from: from, to: to, kind: kind);
      _updateStatistics();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Obtener total pendiente
  Future<void> loadTotalPendingAmount({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      final totalPending = await _service.getTotalPendingAmount(from: from, to: to, kind: kind);
      totalDebtAmount = totalPending;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // ð Crear deuda
  Future<void> addDebt(NewDebtDTO dto) async {
    _setError(null);
    
    try {
      await _service.createDebt(dto);
      
      // Recargar la lista completa desde el servidor inmediatamente
      await loadDebts();
    } catch (e) {
      
      // Aún así, intentar recargar la lista por si la deuda fue creada
      try {
        await loadDebts();
      } catch (reloadError) {
      }
      
      // No hacer rethrow para evitar mostrar error al usuario si la deuda fue realmente creada
      // _setError(e.toString());
      // rethrow;
    }
  }

  // ð Crear múltiples deudas (batch)
  Future<void> addDebtsBatch(List<NewDebtDTO> dtos) async {
    _setError(null);
    
    try {
      await _service.createDebtsBatch(dtos);
      
      // Recargar la lista completa desde el servidor inmediatamente
      await loadDebts();
    } catch (e) {
      
      // Aún así, intentar recargar la lista por si las deudas fueron creadas
      try {
        await loadDebts();
      } catch (reloadError) {
      }
      
      // No hacer rethrow para evitar mostrar error al usuario si las deudas fueron realmente creadas
      // _setError(e.toString());
      // rethrow;
    }
  }

  // ð Actualizar deuda
  Future<void> updateDebt(DebtDTO dto) async {
    
    _setError(null);
    
    try {
      final updatedDebt = await _service.updateDebt(dto);
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Actualizar múltiples deudas (batch)
  Future<void> updateDebtsBatch(List<DebtDTO> dtos) async {
    _setError(null);
    
    try {
      final updatedDebts = await _service.updateDebtsBatch(dtos);
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Eliminar deuda
  Future<void> deleteDebt(int id) async {
    _setLoading(true);
    try {
      await _service.deleteDebt(id);
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ð Eliminar múltiples deudas (batch)
  Future<void> deleteDebtsBatch(List<int> ids) async {
    _setError(null);
    
    try {
      await _service.deleteDebtsBatch(ids);
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= NEW DEBT SPECIFIC METHODS =============

  // ð Realizar pago de deuda
  Future<void> makeDebtPayment(DebtPaymentDTO dto) async {
    _setError(null);
    
    try {
      final paymentResult = await _service.makePayment(dto);
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Actualizar estado de deuda
  Future<void> updateDebtState(int id, StateDebt state) async {
    _setError(null);
    
    try {
      final result = await _service.updateDebtState(id, state);
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= ANALYSIS METHODS =============

  // ð Obtener análisis mensual de deudas
  Future<void> loadMonthlyDebtAnalysis(int year, int month) async {
    _setLoading(true);
    try {
      final from = '$year-${month.toString().padLeft(2, '0')}-01';
      final to = '$year-${month.toString().padLeft(2, '0')}-31';
      final monthlyDebts = await _service.getAllDebts(from: from, to: to);
      double total = 0.0;
      for (final debt in monthlyDebts) {
        total += debt.totalAmount.toDouble();
      }
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Obtener análisis anual de deudas
  Future<void> loadYearlyDebtAnalysis(int year) async {
    _setLoading(true);
    try {
      final from = '$year-01-01';
      final to = '$year-12-31';
      final yearlyDebts = await _service.getAllDebts(from: from, to: to);
      double totalAmount = 0.0;
      for (final debt in yearlyDebts) {
        totalAmount += debt.totalAmount.toDouble();
      }
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Obtener deudas activas
  Future<void> loadActiveDebts() async {
    await loadDebtsByState(StateDebt.ACTIVE);
  }

  // ð Cargar deudas activas usando el nuevo método
  Future<void> loadActiveDebtsNew() async {
    _setLoading(true);
    try {
      debts = await _service.getActiveDebts();
      _updateStatistics();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Marcar deuda como pagada
  Future<void> markDebtAsPaid(int debtId) async {
    try {
      await _service.markDebtAsPaid(debtId);
      
      // Recargar la lista completa desde el servidor
      await loadDebts();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Calcular total de deudas por fecha de vencimiento
  Future<void> loadDebtsByDueDate(DateTime dueDate) async {
    _setLoading(true);
    try {
      // Usar loadDebtsExpiringSoon para obtener deudas próximas a vencer
      final daysDifference = dueDate.difference(DateTime.now()).inDays;
      if (daysDifference > 0) {
        await loadDebtsExpiringSoon(daysDifference);
      } else {
        await loadOverdueDebts();
      }
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= UTILITY METHODS =============

  // ð Limpiar datos
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

  // ð Obtener deuda por ID (desde la lista local)
  DebtDTO? getDebtById(int id) {
    try {
      return debts.firstWhere((debt) => debt.id == id);
    } catch (e) {
      return null;
    }
  }

  // ð Obtener deudas por estado (desde la lista local)
  List<DebtDTO> getDebtsByStateLocal(StateDebt state) {
    return debts.where((debt) => debt.state == state).toList();
  }

  // ð Obtener deudas por rango de fechas (desde la lista local)
  List<DebtDTO> getDebtsByDateRangeLocal(DateTime from, DateTime to) {
    return debts.where((debt) {
      final debtStartDate = debt.startDate;
      return debtStartDate.isAfter(from.subtract(const Duration(days: 1))) &&
             debtStartDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  // ð Obtener deudas por rango de monto (desde la lista local)
  List<DebtDTO> getDebtsByAmountRangeLocal(double minAmount, double maxAmount) {
    return debts.where((debt) => 
        debt.totalAmount.toDouble() >= minAmount && 
        debt.totalAmount.toDouble() <= maxAmount).toList();
  }

  // ð Verificar si hay deudas cargadas
  bool get hasDebts => debts.isNotEmpty;

  // ð Obtener la mayor deuda
  DebtDTO? get highestDebt {
    if (debts.isEmpty) return null;
    return debts.reduce((current, next) => 
        current.totalAmount > next.totalAmount ? current : next);
  }

  // ð Obtener la menor deuda
  DebtDTO? get lowestDebt {
    if (debts.isEmpty) return null;
    return debts.reduce((current, next) => 
        current.totalAmount < next.totalAmount ? current : next);
  }

  // ð Obtener deudas recientes (últimos 30 días)
  List<DebtDTO> get recentDebts {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return debts.where((debt) {
      return debt.startDate.isAfter(thirtyDaysAgo);
    }).toList();
  }

  // ð Obtener deudas activas (desde la lista local)
  List<DebtDTO> get activeDebtsLocal {
    return debts.where((debt) => debt.state == StateDebt.ACTIVE).toList();
  }

  // ð Obtener deudas vencidas (desde la lista local)  
  List<DebtDTO> get overdueDebtsLocal {
    return debts.where((debt) => debt.state == StateDebt.DEFEATED).toList();
  }

  // ð Obtener deudas pagadas (desde la lista local)
  List<DebtDTO> get paidDebtsLocal {
    return debts.where((debt) => debt.state == StateDebt.PAID).toList();
  }

  // ð Obtener deudas por prioridad (ordenadas por monto pendiente descendente)
  List<DebtDTO> get debtsByPriority {
    List<DebtDTO> sortedDebts = List.from(debts);
    sortedDebts.sort((a, b) => b.pendingAmount.compareTo(a.pendingAmount));
    return sortedDebts;
  }

  // ð Obtener resumen de estado de deudas
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

  // ð Crear múltiples deudas
  Future<void> addMultipleDebts(List<NewDebtDTO> dtos) async {
    await addDebtsBatch(dtos);
  }

  // ð Actualizar múltiples deudas  
  Future<void> updateMultipleDebts(List<DebtDTO> dtos) async {
    await updateDebtsBatch(dtos);
  }

  // ð Eliminar múltiples deudas
  Future<void> deleteMultipleDebts(List<int> ids) async {
    await deleteDebtsBatch(ids);
  }

  // ============= DEBT ENROLLMENT METHODS =============

  // ð Cargar enrollments de deudas
  Future<void> loadEnrollments({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      // Use getEnrollmentsByUser for USER role (business accounts)
      enrollments = await _service.getEnrollmentsByUser(from: from, to: to, kind: kind);
      _setError(null);
    } catch (e) {
      // Si es un error de "no hay datos" o lista vacía, no es realmente un error
      if (e.toString().toLowerCase().contains('empty') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found') ||
          e.toString().contains('404')) {
        enrollments = []; // Asegurar lista vacía
        _setError(null); // No mostrar como error
      } else {
        _setError('Error al cargar asignaciones de deudas: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar enrollments por usuario (para cuentas de negocio)
  Future<void> loadEnrollmentsByUser({String? from, String? to, String? kind}) async {
    _setLoading(true);
    try {
      enrollments = await _service.getEnrollmentsByUser(from: from, to: to, kind: kind);
      _setError(null);
    } catch (e) {
      if (e.toString().toLowerCase().contains('empty') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found') ||
          e.toString().contains('404')) {
        enrollments = [];
        _setError(null);
      } else {
        _setError('Error al cargar asignaciones de deudas de usuario: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // ð Asignar deuda a perfil
  Future<void> enrollProfileToDebt(int profileId, int debtId) async {
    _setError(null);
    try {
      final enrollment = await _service.enrollProfileToDebt(profileId, debtId);
      
      // Agregar enrollment a la lista local
      enrollments.add(enrollment);
      
      // Solo notificar cambios sin recargar desde servidor (ya está en local)
      notifyListeners();
    } catch (e) {
      _setError('Error al asignar deuda al perfil: $e');
      rethrow;
    }
  }

  // ð Asignar múltiples deudas a perfil (batch)
  Future<void> enrollProfileToDebtsBatch(List<Map<String, int>> enrollmentData) async {
    _setError(null);
    try {
      final newEnrollments = await _service.enrollProfileToDebtsBatch(enrollmentData);
      
      // Agregar nuevos enrollments a la lista local
      enrollments.addAll(newEnrollments);
      
      // Solo notificar cambios sin recargar desde servidor (ya está en local)
      notifyListeners();
    } catch (e) {
      _setError('Error al asignar deudas al perfil: $e');
      rethrow;
    }
  }

  // ð Remover enrollment de deuda
  Future<void> removeDebtEnrollment(int id) async {
    _setError(null);
    try {
      await _service.removeDebtEnrollment(id);
      
      // Remove enrollment from local list using enrollment ID
      enrollments.removeWhere((enrollment) => enrollment.enrollmentId == id);
      
      // Solo notificar cambios sin recargar desde servidor (ya se eliminó de local)
      notifyListeners();
    } catch (e) {
      _setError('Error al remover asignación de deuda: $e');
      rethrow;
    }
  }

  // ð Remover múltiples enrollments de deudas (batch)
  Future<void> removeDebtEnrollmentsBatch(List<int> ids) async {
    _setError(null);
    try {
      await _service.removeDebtEnrollmentsBatch(ids);
      
      // Remove enrollments from local list using enrollment IDs
      enrollments.removeWhere((enrollment) => ids.contains(enrollment.enrollmentId));
      
      // Solo notificar cambios sin recargar desde servidor (ya se eliminaron de local)
      notifyListeners();
    } catch (e) {
      _setError('Error al remover asignaciones de deudas: $e');
      rethrow;
    }
  }

  // ð Limpiar enrollments
  void clearEnrollments() {
    enrollments.clear();
    notifyListeners();
  }

  // ð Obtener enrollment por deuda ID
  DebtEnrollmentDTO? getEnrollmentByDebtId(int debtId) {
    try {
      return enrollments.firstWhere((enrollment) => enrollment.debtId == debtId);
    } catch (e) {
      return null;
    }
  }

  // ð Verificar si hay enrollments cargados
  bool get hasEnrollments => enrollments.isNotEmpty;

  // ð Obtener enrollments por nombre de deuda
  List<DebtEnrollmentDTO> getEnrollmentsByDebtName(String debtName) {
    return enrollments.where((enrollment) => 
        enrollment.debtName.toLowerCase().contains(debtName.toLowerCase())).toList();
  }
}
