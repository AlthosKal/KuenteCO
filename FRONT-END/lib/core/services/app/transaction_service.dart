import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../../../dto/app/transaction/kuenteco/profile_with_transactions_dto.dart';
import '../../../dto/app/transaction/kuenteco/user_profiles_with_transactions_dto.dart';
import '../../../dto/app/category/transactions_by_category_dto.dart';
import '../../../dto/app/transaction/bancolombia/bancolombia_transaction_request_dto.dart';
import '../api_client.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  // ============= TRANSACTION ENDPOINTS =============

  // ✅ GET /transaction - Get all transactions
  Future<List<TransactionDetailDTO>> getAllTransactions() async {
    print('🚀 TransactionService: Starting getAllTransactions() - About to make GET /transaction request');
    try {
      final response = await _apiClient.getApp('/transaction');
      print('📡 TransactionService: Received response from GET /transaction');
      print('📡 TransactionService: Response status code: ${response.statusCode}');
    
    print('📌 TransactionService: Raw response data type: ${response.data.runtimeType}');
    print('📌 TransactionService: Raw response data: ${response.data}');
    
    final responseData = response.data;
    
    if (responseData is String) {
      print('📌 TransactionService: Response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      print('📌 TransactionService: Response has data key, extracting list');
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        // Caso 1: data es directamente una lista (para perfiles)
        dataList = dataValue;
      } else if (dataValue is Map<String, dynamic> && dataValue.containsKey('profiles')) {
        // Caso 2: data es un mapa con profiles (para usuarios de negocio)
        print('📌 TransactionService: Found business user format with profiles');
        final profiles = dataValue['profiles'] as List<dynamic>;
        dataList = [];
        
        // Extraer todas las transacciones de todos los perfiles
        for (final profile in profiles) {
          if (profile is Map<String, dynamic> && profile.containsKey('transactions')) {
            final transactions = profile['transactions'] as List<dynamic>;
            dataList.addAll(transactions);
            print('📌 TransactionService: Added ${transactions.length} transactions from profile: ${profile['email']}');
          }
        }
        print('📌 TransactionService: Total transactions extracted from profiles: ${dataList.length}');
      } else if (dataValue is String) {
        print('📌 TransactionService: Data field is a string message, returning empty list');
        return [];
      } else {
        print('❌ TransactionService: Data key exists but value is not a List, String or Map with profiles, it is ${dataValue.runtimeType}');
        print('❌ TransactionService: Data field content: $dataValue');
        return [];
      }
    } else if (responseData is List<dynamic>) {
      print('📌 TransactionService: Response is direct list');
      dataList = responseData;
    } else {
      print('❌ TransactionService: Response is not a Map with data key or List, it is ${responseData.runtimeType}');
      print('❌ TransactionService: Response content: $responseData');
      return [];
    }
    
    print('📌 TransactionService: Data list length: ${dataList.length}');
    
    return dataList
        .map((e) => TransactionDetailDTO.fromJson(e as Map<String, dynamic>))
        .toList();
    } catch (e) {
      print('❌ TransactionService: Exception in getAllTransactions(): $e');
      throw e;
    }
  }

  // ✅ GET /transaction/{id} - Get transaction by ID
  Future<TransactionDetailDTO> getTransactionById(int id) async {
    final response = await _apiClient.getApp('/transaction/$id');
    return TransactionDetailDTO.fromJson(response.data);
  }

  // ✅ GET /transaction/summary - Get transaction summary
  Future<List<TransactionSummaryDTO>> getTransactionSummary() async {
    final response = await _apiClient.getApp('/transaction/summary');
    
    print('📌 TransactionService: Transaction summary raw response: ${response.data.runtimeType}');
    print('📌 TransactionService: Transaction summary raw data: ${response.data}');
    
    final responseData = response.data;
    
    if (responseData is String) {
      print('📌 TransactionService: Summary response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      
      print('📌 TransactionService: Data field type: ${dataValue.runtimeType}');
      print('📌 TransactionService: Data field content: $dataValue');
      
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else if (dataValue is String) {
        print('📌 TransactionService: Summary data field is a string message, returning empty list');
        return [];
      } else {
        // Si es otro tipo (Map, etc), mostrar error y devolver lista vacía
        print('❌ TransactionService: Summary data field is not a List or String, it is ${dataValue.runtimeType}');
        print('❌ TransactionService: Data field content: $dataValue');
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      print('❌ TransactionService: Response is not a Map with data key or List, it is ${responseData.runtimeType}');
      print('❌ TransactionService: Response content: $responseData');
      return [];
    }
    
    print('📌 TransactionService: Processing ${dataList.length} transaction summaries');
    
    return dataList
        .map((e) => TransactionSummaryDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ✅ GET /transaction/profiles - Get user profiles with transactions
  Future<UserProfilesWithTransactionsDTO> getProfilesWithTransactions() async {
    final response = await _apiClient.getApp('/transaction/profiles');
    return UserProfilesWithTransactionsDTO.fromJson(response.data);
  }

  // ✅ GET /transaction/profile/{profileId} - Get profile with transactions
  Future<ProfileWithTransactionsDTO> getProfileTransactions(int profileId) async {
    final response = await _apiClient.getApp('/transaction/profile/$profileId');
    return ProfileWithTransactionsDTO.fromJson(response.data);
  }

  // ✅ GET /transaction/category/summary - Get transactions by category summary
  Future<List<TransactionsByCategoryDTO>> getTransactionsByCategory() async {
    final response = await _apiClient.getApp('/transaction/category/summary');
    
    final responseData = response.data;
    
    if (responseData is String) {
      print('📌 TransactionService: Category summary response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        print('❌ TransactionService: Category data key exists but value is not a List, it is ${dataValue.runtimeType}');
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      print('❌ TransactionService: Unknown category summary response format, returning empty list');
      return [];
    }
    
    return dataList
        .map((e) => TransactionsByCategoryDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ✅ POST /transaction/add - Create new transaction
  Future<TransactionDetailDTO> addTransaction(NewTransactionDTO dto) async {
    print('📌 TransactionService: Creating transaction with payload: ${dto.toJson()}');
    
    final response = await _apiClient.postApp('/transaction/add', dto.toJson());
    
    print('📡 TransactionService: Create response status: ${response.statusCode}');
    print('📡 TransactionService: Create response data: ${response.data}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create transaction: ${response.statusCode}');
    }
    
    return TransactionDetailDTO.fromJson(response.data);
  }

  // ✅ POST /transaction/add/batch - Create multiple transactions
  Future<List<TransactionDetailDTO>> addTransactionsBatch(List<NewTransactionDTO> dtos) async {
    print('📌 TransactionService: Creating ${dtos.length} transactions in batch');
    
    final response = await _apiClient.postApp(
      '/transaction/add/batch',
      dtos.map((e) => e.toJson()).toList(),
    );
    
    print('📡 TransactionService: Batch create response status: ${response.statusCode}');
    print('📡 TransactionService: Batch create response data: ${response.data}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create transactions in batch: ${response.statusCode}');
    }
    
    final responseData = response.data;
    List<dynamic> dataList;
    
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
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

  // ✅ PATCH /transaction/update - Update transaction
  Future<TransactionDetailDTO> updateTransaction(UpdateTransactionDTO dto) async {
    print('📌 TransactionService: Updating transaction with payload: ${dto.toJson()}');
    
    final response = await _apiClient.patchApp('/transaction/update', dto.toJson());
    
    print('📡 TransactionService: Update response status: ${response.statusCode}');
    print('📡 TransactionService: Update response data: ${response.data}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update transaction: ${response.statusCode}');
    }
    
    return TransactionDetailDTO.fromJson(response.data);
  }

  // ✅ PUT /transaction/update/batch - Update multiple transactions
  Future<List<TransactionDetailDTO>> updateTransactionsBatch(List<UpdateTransactionDTO> dtos) async {
    print('📌 TransactionService: Updating ${dtos.length} transactions in batch');
    
    final response = await _apiClient.putApp(
      '/transaction/update/batch',
      dtos.map((e) => e.toJson()).toList(),
    );
    
    print('📡 TransactionService: Batch update response status: ${response.statusCode}');
    print('📡 TransactionService: Batch update response data: ${response.data}');
    
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

  // ✅ DELETE /transaction/{id} - Delete transaction by ID
  Future<void> deleteTransaction(int id) async {
    print('📌 TransactionService: Deleting transaction ID: $id');
    
    final response = await _apiClient.deleteApp('/transaction/$id');
    
    print('📡 TransactionService: Delete response status: ${response.statusCode}');
    print('📡 TransactionService: Delete response data: ${response.data}');
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete transaction: ${response.statusCode}');
    }
    
    print('✅ TransactionService: Transaction deleted successfully');
  }

  // ✅ DELETE /transaction/batch - Delete multiple transactions
  Future<void> deleteTransactionsBatch(List<int> ids) async {
    print('📌 TransactionService: Deleting ${ids.length} transactions in batch');
    print('📌 TransactionService: Transaction IDs to delete: $ids');
    
    if (ids.isEmpty) {
      print('📌 TransactionService: No transaction IDs provided, nothing to delete');
      return;
    }
    
    // El backend espera parámetros de query: ?id=1&id=2&id=3
    final queryParams = ids.map((id) => 'id=$id').join('&');
    
    final response = await _apiClient.deleteApp('/transaction/batch?$queryParams');
    
    print('📡 TransactionService: Batch delete response status: ${response.statusCode}');
    print('📡 TransactionService: Batch delete response data: ${response.data}');
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete transactions in batch: ${response.statusCode}');
    }
    
    print('✅ TransactionService: Transactions deleted successfully in batch');
  }

  // ============= BANCOLOMBIA INTEGRATION =============

  // ✅ POST /transaction/bancolombia/sync - Sync transactions from Bancolombia
  Future<List<TransactionDetailDTO>> syncBancolombiaTransactions(
      BancolombiaTransactionRequestDTO dto) async {
    print('📌 TransactionService: Syncing Bancolombia transactions');
    
    final response = await _apiClient.postApp('/transaction/bancolombia/sync', dto.toJson());
    
    print('📡 TransactionService: Bancolombia sync response status: ${response.statusCode}');
    print('📡 TransactionService: Bancolombia sync response data: ${response.data}');
    
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
        print('❌ TransactionService: Bancolombia data key exists but value is not a List, it is ${dataValue.runtimeType}');
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      print('❌ TransactionService: Unknown Bancolombia sync response format, returning empty list');
      return [];
    }
    
    return dataList
        .map((e) => TransactionDetailDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ============= FILTERING AND SEARCH =============

  // ✅ GET /transaction/filter - Filter transactions by criteria
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
    
    print('📌 TransactionService: Filtering transactions with query: $query');
    
    final response = await _apiClient.getApp('/transaction/filter$query');
    
    final responseData = response.data;
    
    if (responseData is String) {
      print('📌 TransactionService: Filter response is string, returning empty list');
      return [];
    }
    
    List<dynamic> dataList;
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is List<dynamic>) {
        dataList = dataValue;
      } else {
        print('❌ TransactionService: Filter data key exists but value is not a List, it is ${dataValue.runtimeType}');
        return [];
      }
    } else if (responseData is List<dynamic>) {
      dataList = responseData;
    } else {
      print('❌ TransactionService: Unknown filter response format, returning empty list');
      return [];
    }
    
    return dataList
        .map((e) => TransactionDetailDTO.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
