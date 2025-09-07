import '../../../dto/app/category/transactions_by_category_dto.dart';
import '../../../dto/app/transaction/bancolombia/bancolombia_transaction_request_dto.dart';
import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/profile_with_transactions_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/user_profiles_with_transactions_dto.dart';
import '../api_client.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  // ============= TRANSACTION ENDPOINTS =============

  // â GET /transaction - Get all transactions
  Future<List<TransactionDetailDTO>> getAllTransactions() async {
    try {
      final response = await _apiClient.getApp('/transaction');
    
    
    final responseData = response.data;
    
    if (responseData is String) {
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        // Caso 1: data es directamente una lista (para perfiles)
        dataList = dataValue;
      } else if (dataValue is Map<String, dynamic> && dataValue.containsKey('profiles')) {
        // Caso 2: data es un mapa con profiles (para usuarios de negocio)
        final profiles = dataValue['profiles'] as List<dynamic>;
        dataList = [];
        
        // Extraer todas las transacciones de todos los perfiles
        for (final profile in profiles) {
          if (profile is Map<String, dynamic> && profile.containsKey('transactions')) {
            final transactions = profile['transactions'] as List<dynamic>;
            dataList.addAll(transactions);
          }
        }
      } else if (dataValue is String) {
        return [];
      } else {
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      return [];
    }
    
    
    return dataList
        .map((e) => TransactionDetailDTO.fromJson(e as Map<String, dynamic>))
        .toList();
    } catch (e) {
      throw e;
    }
  }

  // â GET /transaction/{id} - Get transaction by ID
  Future<TransactionDetailDTO> getTransactionById(int id) async {
    final response = await _apiClient.getApp('/transaction/$id');
    return TransactionDetailDTO.fromJson(response.data);
  }

  // â GET /transaction/summary - Get transaction summary
  Future<List<TransactionSummaryDTO>> getTransactionSummary() async {
    final response = await _apiClient.getApp('/transaction/report/summary');
    
    
    final responseData = response.data;
    
    if (responseData is String) {
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      
      
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else if (dataValue is String) {
        return [];
      } else {
        // Si es otro tipo (Map, etc), mostrar error y devolver lista vacía
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      return [];
    }
    
    
    return dataList
        .map((e) => TransactionSummaryDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // â GET /transaction/profiles - Get user profiles with transactions
  Future<UserProfilesWithTransactionsDTO> getProfilesWithTransactions() async {
    final response = await _apiClient.getApp('/transaction/profiles');
    return UserProfilesWithTransactionsDTO.fromJson(response.data);
  }

  // â GET /transaction/profile/{profileId} - Get profile with transactions
  Future<ProfileWithTransactionsDTO> getProfileTransactions(int profileId) async {
    final response = await _apiClient.getApp('/transaction/profile/$profileId');
    return ProfileWithTransactionsDTO.fromJson(response.data);
  }

  // â GET /transaction/category/summary - Get transactions by category summary
  Future<List<TransactionsByCategoryDTO>> getTransactionsByCategory() async {
    final response = await _apiClient.getApp('/transaction/category/summary');
    
    final responseData = response.data;
    
    if (responseData is String) {
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      return [];
    }
    
    return dataList
        .map((e) => TransactionsByCategoryDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // â POST /transaction/add - Create new transaction
  Future<TransactionDetailDTO> addTransaction(NewTransactionDTO dto) async {
    
    final response = await _apiClient.postApp('/transaction/add', dto.toJson());
    
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create transaction: ${response.statusCode}');
    }
    
    return TransactionDetailDTO.fromJson(response.data);
  }

  // â POST /transaction/add/batch - Create multiple transactions
  Future<List<TransactionDetailDTO>> addTransactionsBatch(List<NewTransactionDTO> dtos) async {
    
    final response = await _apiClient.postApp(
      '/transaction/batch/add',
      dtos.map((e) => e.toJson()).toList(),
    );
    
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create transactions in batch: ${response.statusCode}');
    }
    
    final responseData = response.data;
    
    // El backend ahora devuelve data: null cuando las transacciones se crean exitosamente
    if (responseData is Map<String, dynamic> && responseData.containsKey('success')) {
      final success = responseData['success'];
      if (success == true) {
        // Devolver lista vacía ya que el backend no retorna las transacciones creadas
        return [];
      } else {
        throw Exception('Batch creation failed: ${responseData['message'] ?? 'Unknown error'}');
      }
    }
    
    // Fallback para otros formatos de respuesta (compatibilidad)
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else if (dataValue == null) {
        // Backend devuelve data: null, esto es válido para operaciones batch
        return [];
      } else {
        throw Exception('Batch create data key exists but value is not a List, it is ${dataValue.runtimeType}');
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      throw Exception('Unexpected batch create response format');
    }
    
    return dataList
        .map((e) => TransactionDetailDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // â PATCH /transaction/update - Update transaction
  Future<TransactionDetailDTO> updateTransaction(UpdateTransactionDTO dto) async {
    
    final response = await _apiClient.patchApp('/transaction/update', dto.toJson());
    
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update transaction: ${response.statusCode}');
    }
    
    return TransactionDetailDTO.fromJson(response.data);
  }

  // â PUT /transaction/update/batch - Update multiple transactions
  Future<List<TransactionDetailDTO>> updateTransactionsBatch(List<UpdateTransactionDTO> dtos) async {
    
    final response = await _apiClient.putApp(
      '/transaction/batch/update',
      dtos.map((e) => e.toJson()).toList(),
    );
    
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update transactions in batch: ${response.statusCode}');
    }
    
    final responseData = response.data;
    List<dynamic> dataList;
    
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        throw Exception('Batch update data key exists but value is not a List, it is ${dataValue.runtimeType}');
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      throw Exception('Unexpected batch update response format');
    }
    
    return dataList
        .map((e) => TransactionDetailDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // â DELETE /transaction/{id} - Delete transaction by ID
  Future<void> deleteTransaction(int id) async {
    
    final response = await _apiClient.deleteApp('/transaction/$id');
    
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete transaction: ${response.statusCode}');
    }
    
  }

  // â DELETE /transaction/batch - Delete multiple transactions
  Future<void> deleteTransactionsBatch(List<int> ids) async {
    
    if (ids.isEmpty) {
      return;
    }
    
    // El backend espera parámetros de query: ?id=1&id=2&id=3
    final queryParams = ids.map((id) => 'id=$id').join('&');
    
    final response = await _apiClient.deleteApp('/transaction/batch?$queryParams');
    
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete transactions in batch: ${response.statusCode}');
    }
    
  }

  // ============= BANCOLOMBIA INTEGRATION =============

  // â POST /transaction/bancolombia/sync - Sync transactions from Bancolombia
  Future<List<TransactionDetailDTO>> syncBancolombiaTransactions(
      BancolombiaTransactionRequestDTO dto) async {
    
    final response = await _apiClient.postApp('/transaction/bancolombia/sync', dto.toJson());
    
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sync Bancolombia transactions: ${response.statusCode}');
    }
    
    final responseData = response.data;
    List<dynamic> dataList;
    
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      return [];
    }
    
    return dataList
        .map((e) => TransactionDetailDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ============= FILTERING AND SEARCH =============

  // â GET /transaction/filter - Filter transactions by criteria
  Future<List<TransactionDetailDTO>> getTransactionsWithFilters({
    int? categoryId,
    int? budgetId,
    int? profileId,
    String? from,
    String? to,
    double? minAmount,
    double? maxAmount,
    String? type,
  }) async {
    final queryParams = <String>[];
    
    if (categoryId != null) queryParams.add('categoryId=$categoryId');
    if (budgetId != null) queryParams.add('budgetId=$budgetId');
    if (profileId != null) queryParams.add('profileId=$profileId');
    if (from != null) queryParams.add('from=$from');
    if (to != null) queryParams.add('to=$to');
    if (minAmount != null) queryParams.add('minAmount=$minAmount');
    if (maxAmount != null) queryParams.add('maxAmount=$maxAmount');
    if (type != null) queryParams.add('type=$type');
    
    final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    
    
    final response = await _apiClient.getApp('/transaction/filter$query');
    
    final responseData = response.data;
    
    if (responseData is String) {
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      return [];
    }
    
    return dataList
        .map((e) => TransactionDetailDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
