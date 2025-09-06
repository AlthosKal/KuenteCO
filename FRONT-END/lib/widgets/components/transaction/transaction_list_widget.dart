import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/transactions/transaction_controller.dart';
import '../../../dto/app/transaction/kuenteco/transaction_detail_dto.dart';
import 'transaction_card_widget.dart';
import 'transaction_filter_widget.dart';

class TransactionListWidget extends StatefulWidget {
  final String? filterType; // 'income', 'expense', 'debt', o null para todas
  final Function(TransactionDetailDTO)? onTransactionTap;
  final Function(TransactionDetailDTO)? onTransactionEdit;
  final Function(TransactionDetailDTO)? onTransactionDelete;
  final bool showFilters;
  final bool showFab;
  final VoidCallback? onAddTransaction;
  final bool compact; // true para mostrar como ListItems, false para Cards

  const TransactionListWidget({
    Key? key,
    this.filterType,
    this.onTransactionTap,
    this.onTransactionEdit,
    this.onTransactionDelete,
    this.showFilters = true,
    this.showFab = true,
    this.onAddTransaction,
    this.compact = false,
  }) : super(key: key);

  @override
  State<TransactionListWidget> createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  bool _showFilters = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  void _loadTransactions() {
    final controller = Provider.of<TransactionController>(context, listen: false);
    controller.loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de bÃºsqueda y filtros
          if (widget.showFilters) _buildSearchAndFilterBar(),
          
          // Panel de filtros
          if (_showFilters && widget.showFilters) 
            TransactionFilterWidget(
              onFiltersChanged: _applyFilters,
              onReset: _resetFilters,
            ),

          // Lista de transacciones
          Expanded(child: _buildTransactionsList()),
          
          // BotÃ³n integrado para agregar transacciÃ³n
          if (widget.showFab && widget.onAddTransaction != null)
            _buildAddTransactionButton(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar transacciones...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(
              Icons.filter_list,
              color: _showFilters ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Consumer<TransactionController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return _buildErrorView(controller.errorMessage!);
        }

        if (controller.transactions.isEmpty) {
          return _buildEmptyView();
        }

        final filteredTransactions = _filterTransactions(controller.transactions);

        if (filteredTransactions.isEmpty) {
          return _buildNoResultsView();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadTransactions(),
          child: widget.compact 
              ? _buildCompactList(filteredTransactions)
              : _buildCardList(filteredTransactions),
        );
      },
    );
  }

  Widget _buildCardList(List<TransactionDetailDTO> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionCardWidget(
          transaction: transaction,
          onTap: () => widget.onTransactionTap?.call(transaction),
          onEdit: () => widget.onTransactionEdit?.call(transaction),
          onDelete: () => _showDeleteDialog(transaction),
          showActions: widget.onTransactionEdit != null || widget.onTransactionDelete != null,
        );
      },
    );
  }

  Widget _buildCompactList(List<TransactionDetailDTO> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionListItemWidget(
          transaction: transaction,
          onTap: () => widget.onTransactionTap?.call(transaction),
        );
      },
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar transacciones',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay transacciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera transacciÃ³n para comenzar a usar la app',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (widget.onAddTransaction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onAddTransaction,
                icon: const Icon(Icons.add),
                label: const Text('Crear TransacciÃ³n'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros tÃ©rminos de bÃºsqueda o ajusta los filtros',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _resetFilters,
              child: const Text('Limpiar Filtros'),
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionDetailDTO> _filterTransactions(List<TransactionDetailDTO> transactions) {
    var filtered = transactions;

    // Filtrar por tipo si se especifica
    if (widget.filterType != null) {
      filtered = filtered.where((transaction) {
        final name = transaction.name.toLowerCase();
        switch (widget.filterType) {
          case 'income':
            return name.contains('ingreso') || name.contains('income');
          case 'expense':
            return name.contains('gasto') || name.contains('expense');
          case 'debt':
            return name.contains('deuda') || name.contains('debt');
          default:
            return true;
        }
      }).toList();
    }

    // Filtrar por bÃºsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (transaction.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Ordenar por fecha (mÃ¡s recientes primero)
    filtered.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return filtered;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _applyFilters(Map<String, dynamic> filters) {
    final controller = Provider.of<TransactionController>(context, listen: false);
    
    controller.loadTransactionsWithFilters(
      categoryId: filters['categoryId'],
      budgetId: filters['budgetId'],
      from: filters['fromDate'],
      to: filters['toDate'],
      minAmount: filters['minAmount'],
      maxAmount: filters['maxAmount'],
      type: filters['type'],
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _showFilters = false;
    });
    _loadTransactions();
  }

  void _showDeleteDialog(TransactionDetailDTO transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar TransacciÃ³n'),
        content: Text('Â¿EstÃ¡s seguro de que deseas eliminar "${transaction.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onTransactionDelete?.call(transaction);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTransactionButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onAddTransaction,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Nueva TransacciÃ³n',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionListItemWidget extends StatelessWidget {
  final TransactionDetailDTO transaction;
  final VoidCallback? onTap;

  const TransactionListItemWidget({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          transactionIcon,
          color: cardColor,
          size: 20,
        ),
      ),
      title: Text(
        transaction.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        transaction.date,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '\$${transaction.amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: cardColor,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
