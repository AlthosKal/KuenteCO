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

  // ✅ Get all debts with optional filters
  Future<List<DebtDTO>> getAllDebts({
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting all debts');
    
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

  // ✅ Get debts by state
  Future<List<DebtDTO>> getDebtsByState(
    StateDebt state, {
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting debts by state: $state');
    
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

  // ✅ Get overdue debts
  Future<List<DebtDTO>> getOverdueDebts({
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting overdue debts');
    
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

  // ✅ Get defeated debts (legacy compatibility for overdue)
  Future<List<DebtDTO>> getDefeatedDebts({
    String? from,
    String? to,
    String? kind,
  }) async {
    return await getDebtsByState(StateDebt.DEFEATED, from: from, to: to, kind: kind);
  }

  // ✅ Get debts expiring soon
  Future<List<DebtDTO>> getDebtsExpiringInDays(
    int days, {
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting debts expiring in $days days');
    
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

  // ✅ Get total pending amount
  Future<double> getTotalPendingAmount({
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting total pending amount');
    
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

  // ✅ Get debt summary report
  Future<DebtSummaryDTO> getDebtSummaryReport({
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting debt summary report');
    
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

  // ✅ Create new debt
  Future<DebtDTO> createDebt(NewDebtDTO dto) async {
    print('📌 DebtService: Creating new debt');
    
    final response = await _apiClient.postApp(
      '$_baseEndpoint/add',
      dto.toJson(),
    );

    if (response.data != null && response.data['data'] != null) {
      return DebtDTO.fromJson(response.data['data']);
    }
    throw Exception('Error creating debt');
  }

  // ✅ Create multiple debts
  Future<List<DebtDTO>> createDebtsBatch(List<NewDebtDTO> dtos) async {
    print('📌 DebtService: Creating ${dtos.length} debts in batch');
    
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

  // ✅ Update debt
  Future<DebtDTO> updateDebt(DebtDTO dto) async {
    print('📌 DebtService: Updating debt ID: ${dto.id}');
    
    final response = await _apiClient.patchApp(
      '$_baseEndpoint/update',
      dto.toJson(),
    );

    if (response.data != null && response.data['data'] != null) {
      return DebtDTO.fromJson(response.data['data']);
    }
    throw Exception('Error updating debt');
  }

  // ✅ Update multiple debts
  Future<List<DebtDTO>> updateDebtsBatch(List<DebtDTO> dtos) async {
    print('📌 DebtService: Updating ${dtos.length} debts in batch');
    
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

  // ✅ Make payment to debt
  Future<Map<String, dynamic>> makePayment(DebtPaymentDTO dto) async {
    print('📌 DebtService: Making payment to debt ID: ${dto.debtId}');
    
    final response = await _apiClient.postApp(
      '$_baseEndpoint/payment',
      dto.toJson(),
    );

    return response.data['data'] ?? {};
  }

  // ✅ Update debt state
  Future<Map<String, dynamic>> updateDebtState(int id, StateDebt state) async {
    print('📌 DebtService: Updating debt state for ID: $id to $state');
    
    final response = await _apiClient.patchApp(
      '$_baseEndpoint/$id/state/${state.name}',
    );

    return response.data['data'] ?? {};
  }

  // ✅ Delete debt
  Future<void> deleteDebt(int id) async {
    print('📌 DebtService: Deleting debt ID: $id');
    
    await _apiClient.deleteApp('$_baseEndpoint/$id');
  }

  // ✅ Delete multiple debts
  Future<void> deleteDebtsBatch(List<int> ids) async {
    print('📌 DebtService: Deleting ${ids.length} debts in batch');
    
    // Note: ApiClient doesn't support query params in DELETE, need to adapt
    await _apiClient.deleteApp(
      '$_baseEndpoint/batch?id=${ids.join(',')}',
    );
  }

  // ============= DEBT ENROLLMENT METHODS =============
  
  // ✅ Get all debt enrollments  
  Future<List<DebtEnrollmentDTO>> getEnrollments({
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting all debt enrollments');
    
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
  
  // ✅ Get assigned debts for profile (from enrollments) - for creating transactions
  Future<List<DebtDTO>> getAssignedDebts({
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting assigned debts for profile');
    
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
      print('❌ DebtService: Error getting assigned debts: $e');
      return [];
    }
  }

  // ✅ Get debt enrollments by user (for business accounts)
  Future<List<DebtEnrollmentDTO>> getEnrollmentsByUser({
    String? from,
    String? to,
    String? kind,
  }) async {
    print('📌 DebtService: Getting debt enrollments by user');
    
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

  // ✅ Enroll profile to debt
  Future<DebtEnrollmentDTO> enrollProfileToDebt(int profileId, int debtId) async {
    print('📌 DebtService: Enrolling profile $profileId to debt $debtId');
    print('📌 DebtService: Endpoint: $_baseEndpoint/enroll/add?profileId=$profileId&debtId=$debtId');
    
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
      print('❌ DebtService: Detailed error enrolling profile to debt: $e');
      
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

  // ✅ Enroll profile to multiple debts (batch)
  Future<List<DebtEnrollmentDTO>> enrollProfileToDebtsBatch(List<Map<String, int>> enrollments) async {
    print('📌 DebtService: Batch enrolling profile to ${enrollments.length} debts');
    
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

  // ✅ Remove debt enrollment
  Future<void> removeDebtEnrollment(int id) async {
    print('📌 DebtService: Removing debt enrollment ID: $id');
    
    await _apiClient.deleteApp('$_baseEndpoint/enroll/$id');
  }

  // ✅ Remove multiple debt enrollments (batch)
  Future<void> removeDebtEnrollmentsBatch(List<int> ids) async {
    print('📌 DebtService: Removing ${ids.length} debt enrollments in batch');
    
    await _apiClient.deleteApp(
      '$_baseEndpoint/enroll/batch?id=${ids.join(',')}',
    );
  }

  // ============= LEGACY COMPATIBILITY =============
  // These methods maintain compatibility with existing transaction-based approach
  
  // ✅ Get all debt transactions (legacy compatibility)
  @Deprecated('Use getAllDebts() instead')
  Future<List<TransactionDetailDTO>> getAllDebtTransactions() async {
    print('⚠️  DebtService: Using deprecated getAllDebtTransactions()');
    // Return empty list as this method should be replaced
    return [];
  }

  // ✅ Mark debt as paid (using new state management)
  Future<void> markDebtAsPaid(int debtId) async {
    print('📌 DebtService: Marking debt ID $debtId as paid');
    await updateDebtState(debtId, StateDebt.PAID);
  }

  // ✅ Get active debts
  Future<List<DebtDTO>> getActiveDebts() async {
    print('📌 DebtService: Getting active debts');
    return await getDebtsByState(StateDebt.ACTIVE);
  }
}
