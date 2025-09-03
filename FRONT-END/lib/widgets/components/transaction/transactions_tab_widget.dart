import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/category_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../../../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../../../utils/enum/transaction_type_enum.dart';
import '../common/detail_modal_widget.dart';
import 'create_multiple_transactions_widget.dart';
import 'create_transaction_widget.dart';
import 'delete_multiple_transactions_widget.dart';
import 'delete_transaction_widget.dart';
import 'edit_multiple_transactions_widget.dart';
import 'edit_transaction_widget.dart';
import 'multiple_operations_widget.dart';
import 'transaction_list_widget.dart';

class TransactionsTabWidget extends StatelessWidget {
  final String? userRole;
  final TransactionController transactionController;
  final CategoryController categoryController;
  final Function() onRefresh;

  const TransactionsTabWidget({
    Key? key,
    required this.userRole,
    required this.transactionController,
    required this.categoryController,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (userRole == 'ROLE_PROFILE')
            MultipleOperationsWidget(
              title: 'Operaciones Múltiples',
              color: Theme.of(context).primaryColor,
              onCreateMultiple: () => _navigateToCreateMultiple(context),
              onEditMultiple: () => _navigateToEditMultiple(context),
              onDeleteMultiple: () => _navigateToDeleteMultiple(context),
            ),
          
          Expanded(
            child: userRole == 'ROLE_PROFILE'
                ? _buildProfileTransactionsView(context)
                : _buildBusinessUserSummaryView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTransactionsView(BuildContext context) {
    return TransactionListWidget(
      onTransactionTap: (transaction) => _showTransactionDetail(context, transaction),
      onTransactionEdit: (transaction) => _editTransaction(context, transaction),
      onTransactionDelete: (transaction) => _deleteTransaction(context, transaction),
      onAddTransaction: () => _showCreateTransactionModal(context),
      showFilters: true,
      showFab: true,
      compact: false,
    );
  }
  
  Widget _buildBusinessUserSummaryView(BuildContext context) {
    return TransactionListWidget(
      onTransactionTap: (transaction) => _showTransactionDetail(context, transaction),
      onTransactionEdit: null,
      onTransactionDelete: null,
      onAddTransaction: null,
      showFilters: true,
      showFab: false,
      compact: false,
    );
  }

  void _showTransactionDetail(BuildContext context, TransactionDetailDTO transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailSheet(context, transaction),
    );
  }

  Widget _buildTransactionDetailSheet(BuildContext context, TransactionDetailDTO transaction) {
    Color cardColor = Colors.blue;
    IconData transactionIcon = Icons.swap_horiz;

    if (transaction.descriptionExtra?.type != null) {
      if (transaction.descriptionExtra!.type == TransactionType.INCOME) {
        cardColor = Colors.green;
        transactionIcon = Icons.trending_up;
      } else if (transaction.descriptionExtra!.type == TransactionType.EXPENSE) {
        cardColor = Colors.orange;
        transactionIcon = Icons.trending_down;
      }
    } else {
      final nameLower = transaction.name.toLowerCase();
      if (nameLower.contains('ingreso') || nameLower.contains('income') || nameLower.contains('salario') || nameLower.contains('salary')) {
        cardColor = Colors.green;
        transactionIcon = Icons.trending_up;
      } else if (nameLower.contains('gasto') || nameLower.contains('expense') || nameLower.contains('egreso')) {
        cardColor = Colors.orange;
        transactionIcon = Icons.trending_down;
      } else if (nameLower.contains('deuda') || nameLower.contains('debt')) {
        cardColor = Colors.red;
        transactionIcon = Icons.account_balance_wallet;
      }
    }

    List<DetailItem> details = [];
    
    if (_getTransactionDescription(transaction).isNotEmpty) {
      details.add(DetailItem(label: 'Descripción', value: _getTransactionDescription(transaction)));
    }
    
    details.add(DetailItem(label: 'Fecha', value: transaction.date));
    
    if (transaction.categoryId != null) {
      details.add(DetailItem(label: 'Categoría ID', value: transaction.categoryId.toString()));
    }
    
    if (transaction.budgetId != null) {
      details.add(DetailItem(label: 'Presupuesto ID', value: transaction.budgetId.toString()));
    }

    List<ActionButton> actions = [];
    
    if (userRole == 'ROLE_PROFILE') {
      actions.addAll([
        ActionButton(
          label: 'Editar',
          icon: Icons.edit,
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
            _editTransaction(context, transaction);
          },
        ),
        ActionButton(
          label: 'Eliminar',
          icon: Icons.delete,
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
            _showDeleteTransactionModal(context, transaction);
          },
        ),
      ]);
    }

    return DetailModalWidget(
      title: transaction.name,
      amount: '\$${transaction.amount.toStringAsFixed(0)}',
      color: cardColor,
      icon: transactionIcon,
      details: details,
      actions: actions,
    );
  }

  String _getTransactionDescription(TransactionDetailDTO transaction) {
    if (transaction.descriptionExtra != null) {
      final desc = transaction.descriptionExtra!.description;
      return (desc != null && desc != 'No description') ? desc : '';
    }
    
    if (transaction.description != null && transaction.description != 'No description') {
      return transaction.description!;
    }
    
    return '';
  }

  void _editTransaction(BuildContext context, TransactionDetailDTO transaction) {
    _showEditTransactionModal(context, transaction);
  }

  void _showCreateTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionController>.value(value: transactionController),
          ChangeNotifierProvider<CategoryController>.value(value: categoryController),
        ],
        child: CreateTransactionWidget(
          onCreateTransaction: (newTransaction) => _createTransaction(context, newTransaction),
          isLoading: transactionController.isLoading,
        ),
      ),
    );
  }

  void _showEditTransactionModal(BuildContext context, TransactionDetailDTO transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionController>.value(value: transactionController),
          ChangeNotifierProvider<CategoryController>.value(value: categoryController),
        ],
        child: EditTransactionWidget(
          transaction: transaction,
          onUpdateTransaction: (updateTransaction) => _updateTransaction(context, updateTransaction),
          isLoading: transactionController.isLoading,
        ),
      ),
    );
  }

  void _showDeleteTransactionModal(BuildContext context, TransactionDetailDTO transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteTransactionWidget(
        transaction: transaction,
        onDeleteTransaction: (transactionToDelete) => _deleteTransaction(context, transactionToDelete),
        isLoading: transactionController.isLoading,
      ),
    );
  }

  void _createTransaction(BuildContext context, NewTransactionDTO newTransaction) async {
    try {
      await transactionController.addTransaction(newTransaction);
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la transacción: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateTransaction(BuildContext context, UpdateTransactionDTO updateTransaction) async {
    try {
      await transactionController.updateTransaction(updateTransaction);
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la transacción: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteTransaction(BuildContext context, TransactionDetailDTO transaction) async {
    try {
      await transactionController.deleteTransaction(transaction.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la transacción: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToCreateMultiple(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionController>.value(value: transactionController),
          ChangeNotifierProvider<CategoryController>.value(value: categoryController),
        ],
        child: const CreateMultipleTransactionsWidget(),
      ),
    );

    if (result == true) {
      onRefresh();
    }
  }

  void _navigateToEditMultiple(BuildContext context) async {
    await transactionController.loadTransactions();
    
    if (transactionController.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay transacciones disponibles para editar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionController>.value(value: transactionController),
          ChangeNotifierProvider<CategoryController>.value(value: categoryController),
        ],
        child: EditMultipleTransactionsWidget(
          controller: transactionController,
          transactionsToEdit: transactionController.transactions,
        ),
      ),
    );

    onRefresh();
  }

  void _navigateToDeleteMultiple(BuildContext context) async {
    await transactionController.loadTransactions();
    
    if (transactionController.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay transacciones disponibles para eliminar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionController>.value(value: transactionController),
        ],
        child: DeleteMultipleTransactionsWidget(
          controller: transactionController,
          transactionsToDelete: transactionController.transactions,
        ),
      ),
    );

    onRefresh();
  }
}