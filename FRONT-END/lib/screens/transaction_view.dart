import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/transaction_controller.dart';
import '../dto/app/transaction/kuenteco/new_transaction_dto.dart';
import '../dto/app/transaction/kuenteco/update_transaction_dto.dart';
import '../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import '../widgets/common/background/background_widget.dart';
import '../widgets/common/navbar/navbar_logged_widget.dart';
import '../widgets/components/transaction/transaction_list_widget.dart';
import '../widgets/components/transaction/transaction_form_widget.dart';
import '../widgets/components/transaction/transaction_statistics_widget.dart';
import '../widgets/components/transaction/create_transaction_widget.dart';
import '../widgets/components/transaction/edit_transaction_widget.dart';
import '../widgets/components/transaction/delete_transaction_widget.dart';
import '../core/services/app/transaction_service.dart';
import '../core/services/app/category_service.dart';
import '../core/services/api_client.dart';
import '../controllers/category_controller.dart';

class TransactionView extends StatefulWidget {
  const TransactionView({Key? key}) : super(key: key);

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TransactionController _transactionController;
  late CategoryController _categoryController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _transactionController = TransactionController(TransactionService(ApiClient()));
    _categoryController = CategoryController(CategoryService(ApiClient()));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transactionController.loadTransactions();
      _categoryController.loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transactionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionController>.value(value: _transactionController),
        ChangeNotifierProvider<CategoryController>.value(value: _categoryController),
      ],
      child: Background(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                /// NAVBAR
                KuentecoLoggedNavbar(
                  currentRoute: '/transactions',
                  onLogout: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),

                /// HEADER CON TABS
                _buildHeader(),

                /// CONTENIDO DE TABS
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      /// TAB 1: LISTA DE TRANSACCIONES
                      _buildTransactionsTab(),
                      
                      /// TAB 2: ESTAD�STICAS
                      _buildStatisticsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// T�TULO
          Text(
            'Transacciones',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona todos tus movimientos financieros',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),

          /// TABS
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.list, size: 20),
                  text: 'Lista',
                ),
                Tab(
                  icon: Icon(Icons.bar_chart, size: 20),
                  text: 'Estad�sticas',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TransactionListWidget(
        onTransactionTap: _showTransactionDetail,
        onTransactionEdit: _editTransaction,
        onTransactionDelete: _deleteTransaction,
        onAddTransaction: () {
          _showCreateTransactionModal();
        },
        showFilters: true,
        showFab: false,
        compact: false,
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SingleChildScrollView(
          child: TransactionStatisticsWidget(),
        ),
      ),
    );
  }


  void _showTransactionDetail(TransactionDetailDTO transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailSheet(transaction),
    );
  }

  Widget _buildTransactionDetailSheet(TransactionDetailDTO transaction) {
    final isIncome = transaction.name.toLowerCase().contains('ingreso') || 
                    transaction.name.toLowerCase().contains('income');
    final isExpense = transaction.name.toLowerCase().contains('gasto') || 
                     transaction.name.toLowerCase().contains('expense');
    final isDebt = transaction.name.toLowerCase().contains('deuda') || 
                   transaction.name.toLowerCase().contains('debt');

    Color cardColor = Colors.blue;
    IconData transactionIcon = Icons.swap_horiz;

    if (isIncome) {
      cardColor = Colors.green;
      transactionIcon = Icons.trending_up;
    } else if (isExpense) {
      cardColor = Colors.orange;
      transactionIcon = Icons.trending_down;
    } else if (isDebt) {
      cardColor = Colors.red;
      transactionIcon = Icons.account_balance_wallet;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transactionIcon,
                    color: cardColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${transaction.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cardColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            /// DETALLES
            if (transaction.description?.isNotEmpty == true) ...[
              _buildDetailRow('Descripci�n', transaction.description!),
              const SizedBox(height: 16),
            ],
            
            _buildDetailRow('Fecha', transaction.date),
            const SizedBox(height: 16),
            
            if (transaction.categoryId != null) ...[
              _buildDetailRow('Categor�a ID', transaction.categoryId.toString()),
              const SizedBox(height: 16),
            ],
            
            if (transaction.budgetId != null) ...[
              _buildDetailRow('Presupuesto ID', transaction.budgetId.toString()),
              const SizedBox(height: 24),
            ],

            /// BOTONES DE ACCI�N
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editTransaction(transaction);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteTransactionModal(transaction);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  void _createTransaction(NewTransactionDTO newTransaction) async {
    try {
      await _transactionController.addTransaction(newTransaction);
      
      if (mounted) {
        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacci�n creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la transacci�n: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateTransaction(UpdateTransactionDTO updateTransaction) async {
    try {
      await _transactionController.updateTransaction(updateTransaction);
      
      if (mounted) {
        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacci�n actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la transacci�n: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editTransaction(TransactionDetailDTO transaction) {
    _showEditTransactionModal(transaction);
  }

  void _showCreateTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionController>.value(value: _transactionController),
          ChangeNotifierProvider<CategoryController>.value(value: _categoryController),
        ],
        child: CreateTransactionWidget(
          onCreateTransaction: (newTransaction) {
            _createTransaction(newTransaction);
          },
          isLoading: _transactionController.isLoading,
        ),
      ),
    );
  }

  void _showEditTransactionModal(TransactionDetailDTO transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<TransactionController>.value(value: _transactionController),
          ChangeNotifierProvider<CategoryController>.value(value: _categoryController),
        ],
        child: EditTransactionWidget(
          transaction: transaction,
          onUpdateTransaction: (updateTransaction) {
            _updateTransaction(updateTransaction);
          },
          isLoading: _transactionController.isLoading,
        ),
      ),
    );
  }

  void _showDeleteTransactionModal(TransactionDetailDTO transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteTransactionWidget(
        transaction: transaction,
        onDeleteTransaction: (transactionToDelete) {
          _deleteTransaction(transactionToDelete);
        },
        isLoading: _transactionController.isLoading,
      ),
    );
  }

  void _deleteTransaction(TransactionDetailDTO transaction) async {
    try {
      await _transactionController.deleteTransaction(transaction.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacci�n eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la transacci�n: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}