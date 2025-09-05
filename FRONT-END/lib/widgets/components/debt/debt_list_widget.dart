import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/debt_controller.dart';
import '../../../dto/app/debt/debt_dto.dart';
import '../../../utils/enum/state_debt_enum.dart';

class DebtListWidget extends StatefulWidget {
  final Function(DebtDTO)? onDebtTap;
  final Function(DebtDTO)? onDebtEdit;
  final Function(DebtDTO)? onDebtDelete;
  final Function(int)? onMarkAsPaid;
  final Function(DebtDTO)? onDebtAssign;
  final bool showFilters;
  final bool showFab;
  final VoidCallback? onAddDebt;
  final bool compact;

  const DebtListWidget({
    Key? key,
    this.onDebtTap,
    this.onDebtEdit,
    this.onDebtDelete,
    this.onMarkAsPaid,
    this.onDebtAssign,
    this.showFilters = true,
    this.showFab = true,
    this.onAddDebt,
    this.compact = false,
  }) : super(key: key);

  @override
  State<DebtListWidget> createState() => _DebtListWidgetState();
}

class _DebtListWidgetState extends State<DebtListWidget> {
  bool _showFilters = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDebts();
    });
  }

  void _loadDebts() {
    final controller = Provider.of<DebtController>(context, listen: false);
    controller.loadDebts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DebtController>(
      builder: (context, controller, child) {
        final filteredDebts = _searchQuery.isEmpty
            ? controller.debts
            : controller.debts.where((debt) =>
                debt.name.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

        if (controller.isLoading && controller.debts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return _buildErrorState(controller);
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              if (widget.showFilters) _buildSearchBar(),
              Expanded(
                child: filteredDebts.isEmpty
                    ? _buildEmptyState()
                    : _buildDebtsList(filteredDebts),
              ),
            ],
          ),
          bottomNavigationBar: widget.showFab && widget.onAddDebt != null
              ? SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onAddDebt,
                        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                        label: const Text(
                          'Nueva Deuda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildErrorState(DebtController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar las deudas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadDebts,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar deudas...',
                prefixIcon: const Icon(Icons.search, color: Colors.red),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsList(List<DebtDTO> debts) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          _loadDebts();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: debts.length,
          itemBuilder: (context, index) {
            final debt = debts[index];
            return _buildDebtCard(debt);
          },
        ),
      ),
    );
  }

  Widget _buildDebtCard(DebtDTO debt) {
    final isOverdue = _isOverdue(debt);
    final cardColor = isOverdue ? Colors.red : Colors.orange;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isOverdue ? Icons.warning : Icons.account_balance_wallet,
            color: cardColor,
            size: 20,
          ),
        ),
        title: Text(
          debt.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${debt.startDate.day}/${debt.startDate.month}/${debt.startDate.year}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            if (isOverdue)
              const Text(
                'VENCIDA',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${debt.totalAmount.toDouble().toStringAsFixed(0)}',
              style: TextStyle(
                color: cardColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (widget.onDebtEdit != null || widget.onDebtDelete != null || widget.onMarkAsPaid != null || widget.onDebtAssign != null)
              PopupMenuButton(
                icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                itemBuilder: (context) => [
                  if (widget.onDebtEdit != null)
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue[600]),
                          const SizedBox(width: 12),
                          const Text('Editar'),
                        ],
                      ),
                    ),
                  if (widget.onMarkAsPaid != null)
                    PopupMenuItem(
                      value: 'pay',
                      child: const Row(
                        children: [
                          Icon(Icons.check, size: 18, color: Colors.green),
                          SizedBox(width: 12),
                          Text('Marcar como pagada'),
                        ],
                      ),
                    ),
                  if (widget.onDebtAssign != null)
                    PopupMenuItem(
                      value: 'assign',
                      child: Row(
                        children: [
                          Icon(Icons.person_add, size: 18, color: Colors.orange[600]),
                          const SizedBox(width: 12),
                          const Text('Asignar al perfil'),
                        ],
                      ),
                    ),
                  if (widget.onDebtDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      widget.onDebtEdit?.call(debt);
                      break;
                    case 'pay':
                      widget.onMarkAsPaid?.call(debt.id);
                      break;
                    case 'assign':
                      widget.onDebtAssign?.call(debt);
                      break;
                    case 'delete':
                      widget.onDebtDelete?.call(debt);
                      break;
                  }
                },
              ),
          ],
        ),
        onTap: widget.onDebtTap != null ? () => widget.onDebtTap!(debt) : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron deudas'
                  : 'No tienes deudas registradas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Comienza agregando tu primera deuda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty && widget.onAddDebt != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onAddDebt,
                icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                label: const Text(
                  'Crear Deuda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isOverdue(DebtDTO debt) {
    final now = DateTime.now();
    final expirationDate = debt.expirationDate;
    
    // Una deuda está vencida si su fecha de vencimiento ya pasó o está marcada como DEFEATED
    return now.isAfter(expirationDate) || debt.state == StateDebt.DEFEATED;
  }
}