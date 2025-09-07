import 'package:flutter/material.dart';

import '../../core/services/app/transaction_service.dart';
import '../../dto/app/category/transactions_by_category_dto.dart';
import '../../dto/app/transaction/bancolombia/bancolombia_transaction_request_dto.dart';
import '../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../dto/app/transaction/kuenteco/profile_with_transactions_dto.dart';
import '../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../dto/app/transaction/kuenteco/transaction_summary_dto.dart';
import '../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../dto/app/transaction/kuenteco/user_profiles_with_transactions_dto.dart';

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

  // ð Cargar todas las transacciones
  Future<void> loadTransactions() async {
    _setLoading(true);
    try {
      transactions = await _service.getAllTransactions();
      
      // Log de todas las transacciones para debug
      for (int i = 0; i < transactions.length; i++) {
        print('   Transaction $i: ID=${transactions[i].id}, Name="${transactions[i].name}", Amount=${transactions[i].amount}');
      }
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar transacción por ID
  Future<void> loadTransactionById(int id) async {
    _setLoading(true);
    try {
      currentTransaction = await _service.getTransactionById(id);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar resumen de transacciones
  Future<void> loadTransactionSummaries() async {
    _setLoading(true);
    try {
      transactionSummaries = await _service.getTransactionSummary();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar perfiles con transacciones (para usuarios de negocio)
  Future<void> loadUserProfilesWithTransactions() async {
    _setLoading(true);
    try {
      userProfilesWithTransactions = await _service.getProfilesWithTransactions();
      
      // Log information about each profile
      if (userProfilesWithTransactions?.profiles != null) {
        for (int i = 0; i < userProfilesWithTransactions!.profiles!.length; i++) {
          final profile = userProfilesWithTransactions!.profiles![i];
          print('   Profile $i: Email=${profile.email}, Transactions=${profile.transactions?.length ?? 0}');
        }
      }
      
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar transacciones por categoría
  Future<void> loadTransactionsByCategory() async {
    _setLoading(true);
    try {
      transactionsByCategory = await _service.getTransactionsByCategory();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar perfiles con transacciones
  Future<void> loadProfilesWithTransactions() async {
    _setLoading(true);
    try {
      userProfilesWithTransactions = await _service.getProfilesWithTransactions();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ð Cargar transacciones de perfil específico
  Future<void> loadProfileTransactions(int profileId) async {
    _setLoading(true);
    try {
      currentProfileWithTransactions = await _service.getProfileTransactions(profileId);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= CRUD OPERATIONS =============

  // ð Crear transacción
  Future<void> addTransaction(NewTransactionDTO dto) async {
    _setError(null);
    
    try {
      final createdTransaction = await _service.addTransaction(dto);
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Crear múltiples transacciones (batch)
  Future<void> addTransactionsBatch(List<NewTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      final createdTransactions = await _service.addTransactionsBatch(dtos);
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Actualizar transacción
  Future<void> updateTransaction(UpdateTransactionDTO dto) async {
    
    _setError(null);
    
    try {
      final updatedTransaction = await _service.updateTransaction(dto);
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Actualizar múltiples transacciones (batch)
  Future<void> updateTransactionsBatch(List<UpdateTransactionDTO> dtos) async {
    _setError(null);
    
    try {
      final updatedTransactions = await _service.updateTransactionsBatch(dtos);
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ð Eliminar transacción
  Future<void> deleteTransaction(int id) async {
    _setLoading(true);
    try {
      await _service.deleteTransaction(id);
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ð Eliminar múltiples transacciones (batch)
  Future<void> deleteTransactionsBatch(List<int> ids) async {
    _setError(null);
    
    try {
      await _service.deleteTransactionsBatch(ids);
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= FILTERING OPERATIONS =============

  // ð Filtrar transacciones
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
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ============= BANCOLOMBIA INTEGRATION =============

  // ð Sincronizar transacciones de Bancolombia
  Future<void> syncBancolombiaTransactions(BancolombiaTransactionRequestDTO dto) async {
    _setError(null);
    
    try {
      final syncedTransactions = await _service.syncBancolombiaTransactions(dto);
      
      // Recargar la lista completa desde el servidor
      await loadTransactions();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // ============= UTILITY METHODS =============

  // ð Limpiar datos
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

  // ð Obtener transacción por ID (desde la lista local)
  TransactionDetailDTO? getTransactionById(int id) {
    try {
      return transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  // ð Obtener conteo total de transacciones
  int get transactionCount => transactions.length;

  // ð Obtener monto total de transacciones
  double get totalAmount {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // ð Verificar si hay transacciones cargadas
  bool get hasTransactions => transactions.isNotEmpty;
}
