import 'package:decimal/decimal.dart';
import '../../../dto/app/debt/new_debt_dto.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../dto/app/debt/debt_enrollment_dto.dart';
import '../../../dto/app/debt/debt_payment_dto.dart';
import '../../../dto/app/debt/debt_summary_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../utils/enum/state_debt_enum.dart';
import '../api_client.dart';

class DebtService {
  final ApiClient _apiClient;
  static const String _baseEndpoint = '/debt';

  DebtService(this._apiClient);

  // ============= DEBT SPECIFIC METHODS =============

  // â Get all debts with optional filters
  Future<List<DebtDTO>> getAllDebts({
    String? from,
    String? to,
    String? kind,
  }) async {
    
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _apiClient.getApp(
      _baseEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtDTO.fromJson(json))
          .toList();
    }
    return [];
  }

  // â Get debts by state
  Future<List<DebtDTO>> getDebtsByState(
    StateDebt state, {
    String? from,
    String? to,
    String? kind,
  }) async {
    
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _apiClient.getApp(
      '$_baseEndpoint/state/${state.name}',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtDTO.fromJson(json))
          .toList();
    }
    return [];
  }

  // â Get overdue debts
  Future<List<DebtDTO>> getOverdueDebts({
    String? from,
    String? to,
    String? kind,
  }) async {
    
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _apiClient.getApp(
      '$_baseEndpoint/overdue',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtDTO.fromJson(json))
          .toList();
    }
    return [];
  }

  // â Get defeated debts (legacy compatibility for overdue)
  Future<List<DebtDTO>> getDefeatedDebts({
    String? from,
    String? to,
    String? kind,
  }) async {
    return await getDebtsByState(StateDebt.DEFEATED, from: from, to: to, kind: kind);
  }

  // â Get debts expiring soon
  Future<List<DebtDTO>> getDebtsExpiringInDays(
    int days, {
    String? from,
    String? to,
    String? kind,
  }) async {
    
    final queryParams = <String, String>{
      'days': days.toString(),
    };
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _apiClient.getApp(
      '$_baseEndpoint/expiring-soon',
      queryParameters: queryParams,
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtDTO.fromJson(json))
          .toList();
    }
    return [];
  }

  // â Get total pending amount
  Future<double> getTotalPendingAmount({
    String? from,
    String? to,
    String? kind,
  }) async {
    
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _apiClient.getApp(
      '$_baseEndpoint/total-pending',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data != null && response.data['data'] != null) {
      // Backend returns a complex object, extract totalPendingAmount
      if (response.data['data'] is Map && response.data['data']['totalPendingAmount'] != null) {
        return (response.data['data']['totalPendingAmount'] as num).toDouble();
      }
      // Fallback if it's just a number
      return (response.data['data'] as num).toDouble();
    }
    return 0.0;
  }

  // â Get debt summary report
  Future<DebtSummaryDTO> getDebtSummaryReport({
    String? from,
    String? to,
    String? kind,
  }) async {
    
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _apiClient.getApp(
      '$_baseEndpoint/report/summary',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data != null && response.data['data'] != null) {
      return DebtSummaryDTO.fromJson(response.data['data']);
    }
    throw Exception('No debt summary data received');
  }

  // ============= DEBT CRUD OPERATIONS =============

  // â Create new debt
  Future<DebtDTO> createDebt(NewDebtDTO dto) async {
    
    final response = await _apiClient.postApp(
      '$_baseEndpoint/add',
      dto.toJson(),
    );

    if (response.data != null && response.data['data'] != null) {
      return DebtDTO.fromJson(response.data['data']);
    }
    throw Exception('Error creating debt');
  }

  // â Create multiple debts
  Future<List<DebtDTO>> createDebtsBatch(List<NewDebtDTO> dtos) async {
    
    final response = await _apiClient.postApp(
      '$_baseEndpoint/batch/add',
      dtos.map((dto) => dto.toJson()).toList(),
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtDTO.fromJson(json))
          .toList();
    }
    throw Exception('Error creating debts in batch');
  }

  // â Update debt
  Future<DebtDTO> updateDebt(DebtDTO dto) async {
    
    final response = await _apiClient.patchApp(
      '$_baseEndpoint/update',
      dto.toJson(),
    );

    if (response.data != null && response.data['data'] != null) {
      return DebtDTO.fromJson(response.data['data']);
    }
    throw Exception('Error updating debt');
  }

  // â Update multiple debts
  Future<List<DebtDTO>> updateDebtsBatch(List<DebtDTO> dtos) async {
    
    final response = await _apiClient.putApp(
      '$_baseEndpoint/batch/update',
      dtos.map((dto) => dto.toJson()).toList(),
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtDTO.fromJson(json))
          .toList();
    }
    throw Exception('Error updating debts in batch');
  }

  // â Make payment to debt
  Future<Map<String, dynamic>> makePayment(DebtPaymentDTO dto) async {
    
    final response = await _apiClient.postApp(
      '$_baseEndpoint/payment',
      dto.toJson(),
    );

    return response.data['data'] ?? {};
  }

  // â Update debt state
  Future<Map<String, dynamic>> updateDebtState(int id, StateDebt state) async {
    
    final response = await _apiClient.patchApp(
      '$_baseEndpoint/$id/state/${state.name}',
    );

    return response.data['data'] ?? {};
  }

  // â Delete debt
  Future<void> deleteDebt(int id) async {
    
    await _apiClient.deleteApp('$_baseEndpoint/$id');
  }

  // â Delete multiple debts
  Future<void> deleteDebtsBatch(List<int> ids) async {
    
    // Note: ApiClient doesn't support query params in DELETE, need to adapt
    await _apiClient.deleteApp(
      '$_baseEndpoint/batch?id=${ids.join(',')}',
    );
  }

  // ============= DEBT ENROLLMENT METHODS =============
  
  // â Get all debt enrollments  
  Future<List<DebtEnrollmentDTO>> getEnrollments({
    String? from,
    String? to,
    String? kind,
  }) async {
    
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _apiClient.getApp(
      '$_baseEndpoint/enroll',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtEnrollmentDTO.fromJson(json))
          .toList();
    }
    return [];
  }
  
  // â Get assigned debts for profile (from enrollments) - for creating transactions
  Future<List<DebtDTO>> getAssignedDebts({
    String? from,
    String? to,
    String? kind,
  }) async {
    
    try {
      // Get enrollments which contain debt information
      final enrollments = await getEnrollments(from: from, to: to, kind: kind);
      
      // Convert enrollments to DebtDTO objects with available information
      return enrollments.where((enrollment) => enrollment.debtId != null)
          .map((enrollment) => DebtDTO(
            id: enrollment.debtId!,
            name: enrollment.debtName,
            totalAmount: Decimal.fromInt(0), // Not available from enrollment
            pendingAmount: Decimal.fromInt(0), // Not available from enrollment
            startDate: DateTime.now(), // Default
            expirationDate: DateTime.now().add(Duration(days: 30)), // Default expiration
            state: StateDebt.ACTIVE, // Assume active
          )).toList();
    } catch (e) {
      return [];
    }
  }

  // â Get debt enrollments by user (for business accounts)
  Future<List<DebtEnrollmentDTO>> getEnrollmentsByUser({
    String? from,
    String? to,
    String? kind,
  }) async {
    
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _apiClient.getApp(
      '$_baseEndpoint/enroll/user',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtEnrollmentDTO.fromJson(json))
          .toList();
    }
    return [];
  }

  // â Enroll profile to debt
  Future<DebtEnrollmentDTO> enrollProfileToDebt(int profileId, int debtId) async {
    
    try {
      final response = await _apiClient.postApp(
        '$_baseEndpoint/enroll/add?profileId=$profileId&debtId=$debtId',
        null, // No body needed since parameters are in query string
      );

      if (response.data != null && response.data['data'] != null) {
        return DebtEnrollmentDTO.fromJson(response.data['data']);
      }
      throw Exception('Error: No data returned from server');
    } catch (e) {
      
      // Try to extract more specific error information
      if (e.toString().contains('404')) {
        throw Exception('Error: Perfil o deuda no encontrados (profileId: $profileId, debtId: $debtId)');
      } else if (e.toString().contains('400')) {
        throw Exception('Error: Datos inválidos para asignación');
      } else if (e.toString().contains('409')) {
        throw Exception('Error: Esta deuda ya está asignada a este perfil');
      } else if (e.toString().contains('500')) {
        throw Exception('Error del servidor: Verifica que el perfil y la deuda existan');
      }
      
      rethrow;
    }
  }

  // â Enroll profile to multiple debts (batch)
  Future<List<DebtEnrollmentDTO>> enrollProfileToDebtsBatch(List<Map<String, int>> enrollments) async {
    
    final response = await _apiClient.postApp(
      '$_baseEndpoint/enroll/add/batch',
      enrollments,
    );

    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => DebtEnrollmentDTO.fromJson(json))
          .toList();
    }
    throw Exception('Error batch enrolling profile to debts');
  }

  // â Remove debt enrollment
  Future<void> removeDebtEnrollment(int id) async {
    
    await _apiClient.deleteApp('$_baseEndpoint/enroll/$id');
  }

  // â Remove multiple debt enrollments (batch)
  Future<void> removeDebtEnrollmentsBatch(List<int> ids) async {
    
    await _apiClient.deleteApp(
      '$_baseEndpoint/enroll/batch?id=${ids.join(',')}',
    );
  }

  // ============= LEGACY COMPATIBILITY =============
  // These methods maintain compatibility with existing transaction-based approach
  
  // â Get all debt transactions (legacy compatibility)
  @Deprecated('Use getAllDebts() instead')
  Future<List<TransactionDetailDTO>> getAllDebtTransactions() async {
    // Return empty list as this method should be replaced
    return [];
  }

  // â Mark debt as paid (using new state management)
  Future<void> markDebtAsPaid(int debtId) async {
    await updateDebtState(debtId, StateDebt.PAID);
  }

  // â Get active debts
  Future<List<DebtDTO>> getActiveDebts() async {
    return await getDebtsByState(StateDebt.ACTIVE);
  }
}
