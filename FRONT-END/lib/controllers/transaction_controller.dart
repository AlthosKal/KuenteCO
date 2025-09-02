import 'package:flutter/material.dart';

import '../core/services/app/transaction_service.dart';
import '../dto/app/category/transactions_by_category_dto.dart';
import '../dto/app/transaction/bancolombia/bancolombia_transaction_request_dto.dart';
import '../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../dto/app/transaction/kuenteco/profile_with_transactions_dto.dart';
import '../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../dto/app/transaction/kuenteco/user_profiles_with_transactions_dto.dart';

class TransactionController extends ChangeNotifier {
  final TransactionService _service;

  bool isLoading = false;
  String? errorMessage;

  List<TransactionDetailDTO> transactions = [];
  List<TransactionSummaryDTO> transactionSummaries = [];
  List<TransactionsByCategoryDTO> transactionsByCategory = [];
  UserProfilesWithTransactionsDTO? userProfilesWithTransactions;
  ProfileWithTransactionsDTO? currentProfileWithTransactions;
  TransactionDetailDTO? currentTransaction;

  TransactionController(this._service);

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  // ============= LOAD OPERATIONS =============

  // 📌 Cargar todas las transacciones
  Future<void> loadTransactions() async {
    _setLoading(true);
    try {
      print('🔄 TransactionController: Loading transactions from server...');
      transactions = await _service.getAllTransactions();
      print('✅ TransactionController: Loaded ${transactions.length} transactions from server');
      
      // Log de todas las transacciones para debug
      for (int i = 0; i < transactions.length; i++) {
        print('   Transaction $i: ID=${transactions[i].id}, Name="${transactions[i].name}", Amount=${transactions[i].amount}');
      }
      
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error loading transactions: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar transacción por ID
  Future<void> loadTransactionById(int id) async {
    _setLoading(true);
    try {
      print('🔄 TransactionController: Loading transaction ID: $id');
      currentTransaction = await _service.getTransactionById(id);
      print('✅ TransactionController: Loaded transaction: ${currentTransaction?.name}');
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error loading transaction: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar resumen de transacciones
  Future<void> loadTransactionSummaries() async {
    _setLoading(true);
    try {
      print('🔄 TransactionController: Loading transaction summaries...');
      transactionSummaries = await _service.getTransactionSummary();
      print('✅ TransactionController: Loaded ${transactionSummaries.length} transaction summaries');
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error loading transaction summaries: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar perfiles con transacciones (para usuarios de negocio)
  Future<void> loadUserProfilesWithTransactions() async {
    _setLoading(true);
    try {
      print('🔄 TransactionController: Loading user profiles with transactions...');
      userProfilesWithTransactions = await _service.getProfilesWithTransactions();
      print('✅ TransactionController: Loaded profiles with transactions for user: ${userProfilesWithTransactions?.username}');
      print('✅ TransactionController: Total profiles: ${userProfilesWithTransactions?.profiles?.length ?? 0}');
      
      // Log information about each profile
      if (userProfilesWithTransactions?.profiles != null) {
        for (int i = 0; i < userProfilesWithTransactions!.profiles!.length; i++) {
          final profile = userProfilesWithTransactions!.profiles![i];
          print('   Profile $i: Email=${profile.email}, Transactions=${profile.transactions?.length ?? 0}');
        }
      }
      
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error loading profiles with transactions: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar transacciones por categoría
  Future<void> loadTransactionsByCategory() async {
    _setLoading(true);
    try {
      print('🔄 TransactionController: Loading transactions by category...');
      transactionsByCategory = await _service.getTransactionsByCategory();
      print('✅ TransactionController: Loaded ${transactionsByCategory.length} category summaries');
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error loading transactions by category: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar perfiles con transacciones
  Future<void> loadProfilesWithTransactions() async {
    _setLoading(true);
    try {
      print('🔄 TransactionController: Loading user profiles with transactions...');
      userProfilesWithTransactions = await _service.getProfilesWithTransactions();
      print('✅ TransactionController: Loaded profiles with transactions for user: ${userProfilesWithTransactions?.username}');
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error loading profiles with transactions: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Cargar transacciones de perfil específico
  Future<void> loadProfileTransactions(int profileId) async {
    _setLoading(true);
    try {
      print('🔄 TransactionController: Loading transactions for profile ID: $profileId');
      currentProfileWithTransactions = await _service.getProfileTransactions(profileId);
      print('✅ TransactionController: Loaded transactions for profile: ${currentProfileWithTransactions?.email}');
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error loading profile transactions: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // 📌 Crear transacción
  Future<void> addTransaction(NewTransactionDTO dto) async {
    _setError(null);
    
    try {
      print('📌 TransactionController: Creating transaction...');
      final createdTransaction = await _service.addTransaction(dto);
      print('✅ TransactionController: Transaction created with ID: ${createdTransaction.id}');
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      print('❌ TransactionController: Error creating transaction: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Crear múltiples transacciones (batch)
  Future<void> addTransactionsBatch(List<NewTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 TransactionController: Creating ${dtos.length} transactions in batch...');
      final createdTransactions = await _service.addTransactionsBatch(dtos);
      print('✅ TransactionController: Batch creation completed. Created ${createdTransactions.length} transactions');
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      print('❌ TransactionController: Error in batch creation: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar transacción
  Future<void> updateTransaction(UpdateTransactionDTO dto) async {
    print('🔄 TransactionController: Starting update for transaction ID: ${dto.id}');
    
    _setError(null);
    
    try {
      print('🔄 TransactionController: Calling service.updateTransaction...');
      final updatedTransaction = await _service.updateTransaction(dto);
      print('✅ TransactionController: Transaction updated successfully: ${updatedTransaction.name}');
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      print('❌ TransactionController: Error during update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Actualizar múltiples transacciones (batch)
  Future<void> updateTransactionsBatch(List<UpdateTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      print('📌 TransactionController: Updating ${dtos.length} transactions in batch...');
      final updatedTransactions = await _service.updateTransactionsBatch(dtos);
      print('✅ TransactionController: Batch update completed. Updated ${updatedTransactions.length} transactions');
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      print('❌ TransactionController: Error in batch update: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // 📌 Eliminar transacción
  Future<void> deleteTransaction(int id) async {
    _setLoading(true);
    try {
      print('📌 TransactionController: Deleting transaction ID: $id');
      await _service.deleteTransaction(id);
      print('✅ TransactionController: Transaction deleted successfully');
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error deleting transaction: $e');
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 📌 Eliminar múltiples transacciones (batch)
  Future<void> deleteTransactionsBatch(List<int> ids) async {
    _setError(null);
    
    try {
      print('📌 TransactionController: Deleting ${ids.length} transactions in batch...');
      await _service.deleteTransactionsBatch(ids);
      print('✅ TransactionController: Batch deletion completed successfully');
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      print('❌ TransactionController: Error in batch deletion: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= FILTERING OPERATIONS =============

  // 📌 Filtrar transacciones
  Future<void> loadTransactionsWithFilters({
    int? categoryId,
    int? budgetId,
    int? profileId,
    String? from,
    String? to,
    double? minAmount,
    double? maxAmount,
    String? type,
  }) async {
    _setLoading(true);
    try {
      print('🔄 TransactionController: Loading filtered transactions...');
      transactions = await _service.getTransactionsWithFilters(
        categoryId: categoryId,
        budgetId: budgetId,
        profileId: profileId,
        from: from,
        to: to,
        minAmount: minAmount,
        maxAmount: maxAmount,
        type: type,
      );
      print('✅ TransactionController: Loaded ${transactions.length} filtered transactions');
      _setError(null);
    } catch (e) {
      print('❌ TransactionController: Error loading filtered transactions: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= BANCOLOMBIA INTEGRATION =============

  // 📌 Sincronizar transacciones de Bancolombia
  Future<void> syncBancolombiaTransactions(BancolombiaTransactionRequestDTO dto) async {
    _setError(null);
    
    try {
      print('📌 TransactionController: Syncing Bancolombia transactions...');
      final syncedTransactions = await _service.syncBancolombiaTransactions(dto);
      print('✅ TransactionController: Bancolombia sync completed. Synced ${syncedTransactions.length} transactions');
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      print('❌ TransactionController: Error syncing Bancolombia transactions: $e');
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= UTILITY METHODS =============

  // 📌 Limpiar datos
  void clearData() {
    transactions.clear();
    transactionSummaries.clear();
    transactionsByCategory.clear();
    userProfilesWithTransactions = null;
    currentProfileWithTransactions = null;
    currentTransaction = null;
    _setError(null);
    notifyListeners();
  }

  // 📌 Obtener transacción por ID (desde la lista local)
  TransactionDetailDTO? getTransactionById(int id) {
    try {
      return transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  // 📌 Obtener conteo total de transacciones
  int get transactionCount => transactions.length;

  // 📌 Obtener monto total de transacciones
  double get totalAmount {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // 📌 Verificar si hay transacciones cargadas
  bool get hasTransactions => transactions.isNotEmpty;
}
